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
    CSV.foreach(file, :headers => true) do |row|
      puts "#{row.class}, #{row.count}, #{row.headers}" if @debug
      match = /-(\d*.\d*)_\d*.csv/.match(file)
      clazzname = match[1]

      row.headers.each do |header|
        next if row.headers.first == header

        data = {
          "class" => clazzname,
          "type" => row[0].gsub(/\s|\//,'_'),
          "timestamp" => timestamp(file),
          "kpi" => header,
          "times" => row[header].to_i,
          "_source" => "script"
        }
        client.index(index: 'logstash-benchmark', type: 'bench', body: data) rescue puts "failure with #{row}"
      end
    end
    puts if @debug
  end

  def timestamp(file)
    match = /(\d*).csv/.match(file)
    Time.at(match[1].to_i).utc.to_s.split(' ').first
  end

  def build_index(client, params)
    client.indices.create index: 'logstash-benchmark', body: params
  end

  def index_config
    props   = { "name"   => { "type" => "string" },
                "class"  => { "type" => "string" },
                "kpi"    => { "type" => "string" },
                "timestamp"   => { "type" => "date", "index" => "analyzed" },
                "times" => { "type" => "integer" } }
    { 'mappings' => { 'bench' => { '_source' => { 'enabled' => true }, 'properties' => props } } }
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
