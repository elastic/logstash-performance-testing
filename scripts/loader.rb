#!/usr/bin/env ruby

require 'elasticsearch'
require 'csv'

class Loader

  def initialize(dir="", debug=false)
    @dir = dir
    @debug = debug
  end

  def run
    Dir.entries(@dir).each do |file|
      absolute_path = File.join(@dir, file)
      next if File.directory?(absolute_path)
      load_file!(client, absolute_path)
    end
  end

  def create_index
    build_index client, index_config
  end

  private

  def client
    @client ||= Elasticsearch::Client.new log: @debug
  end

  def load_file!(client, file)
    puts file if @debug
    props = scrap_props(file)
    CSV.foreach(file, :headers => true) do |row|
      puts "#{row.class}, #{row.count}, #{row.headers}" if @debug
      row.headers.each do |header|
        next if row.headers.first == header
        content = build_body(row, header, props)
        id   = "#{props[:time]}#{content["type"]}#{content["kpi"]}".hash
        client.index(index: 'logstash-benchmark', type: 'bench', id: id, body: content) rescue puts "failure with #{row}"
      end
    end
    puts if @debug
  end

  def build_body(row, header, props)
    type = row[0]
    kpi  = header
    {
      "class" => props[:class],
      "type" => type,
      "ts" => timestamp(props[:time]),
      "kpi" => kpi,
      "times" => row[header].to_i,
      "_source" => "script"
    }
  end

  def timestamp(time)
    Time.at(time.to_i).strftime("%Y-%m-%dT%H:%M:%S.%3N%z")
  end

  def scrap_props(file)
    match = /-(\d*.\d*)_(\d*).csv/.match(file)
    {:class => match[1], :time => match[2] }
  end

  def build_index(client, params)
    client.indices.create index: 'logstash-benchmark', body: params
  end

  def index_config
    {:settings => index_settings, :mappings => index_mappings }
  end

  def index_settings
    { analysis: {analyzer: {
      label: {
        stopwords: '_none_',
        type: 'standard'
      }
    }}}
  end

  def index_mappings
    props   = { "name"  => { "type" => "string" },
                "class" => { "type" => "string" },
                "type"  => { "type" => "string", "index" => "not_analyzed" },
                "kpi"   => { "type" => "string", "index" => "not_analyzed" },
                "ts"  => { "type" => "date", "format" => "yyyy-MM-dd'T'HH:mm:ss.SSSZ", "index" => "analyzed" },
                "times" => { "type" => "integer" } }
    { 'bench' => { '_source' => { 'enabled' => true }, 'properties' => props } }
  end

end

  @debug = !!ENV['DEBUG']

  ## main function
  if __FILE__ == $0
    mode   = ARGV[0]
    if "i" == mode
      puts "Loading the index definition"
      Loader.new.create_index
      puts "done"
    elsif "m" == mode
      puts "Loading data form the directory"
      loader = Loader.new(ARGV[1], @debug)
      loader.run
      puts "done"
    else
      raise Exception.new("IllegalArgument: USAGE: loader [m|i] [path]")
    end
  end
