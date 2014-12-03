# encoding: utf-8

puts "installing dependencies..."

base_dir = (ARGV.size < 1 ?  Dir.pwd : ARGV[0])
logstash = File.join(base_dir, "bin", "logstash")
version = `#{logstash} --version`

if version[/\d\.\d\.\d/] =~ /1\.4\./
  # why do deps here? can't we assume you must have a working logstash distribution?
  # `#{logstash} deps 2>&1`
else
  inputs  = ['stdin'].map{|s| "input-#{s}"}
  outputs = ['stdout'].map{|s| "output-#{s}"}
  filters = ['clone', 'json', 'grok', 'syslog_pri', 'date', 'mutate'].map{|s| "filter-#{s}"}

  # why do bootstrap here? can't we assume you must have a working logstash distribution?
  # `#{rake} bootstrap`

  [inputs, outputs, filters].each do |plugins|
    plugins.map{|s| "logstash-#{s}"}.each do |plugin|
      puts(`#{logstash} plugin install #{plugin}`)
    end
  end
end

puts "done!"
