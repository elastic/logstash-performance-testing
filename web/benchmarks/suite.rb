module LogStash::PerformanceMeter

  base_dir = "/home/purbon/logstash-performance-testing/benchmarks"

  DEFAULT_SUITE = [ { :name => "simple line in/out", :config => "#{base_dir}/config/simple.conf", :input => "#{base_dir}/input/simple_10.txt", :time => 120 },
                    { :name => "simple line in/json out", :config => "#{base_dir}/config/simple_json_out.conf", :input => "#{base_dir}/input/simple_10.txt", :time => 120 },
                    { :name => "json codec in/out", :config => "#{base_dir}/config/json_inout_codec.conf", :input => "#{base_dir}/input/json_medium.txt", :time => 120 },
                    { :name => "line in/json filter/json out", :config => "#{base_dir}/config/json_inout_filter.conf", :input => "#{base_dir}/input/json_medium.txt", :time => 120 },
                    { :name => "apache in/json out", :config => "#{base_dir}/config/simple.conf", :input => "#{base_dir}/input/apache_log.txt", :time => 120 },
                    { :name => "apache in/grok codec/json out", :config => "#{base_dir}/config/simple_grok.conf", :input => "#{base_dir}/input/apache_log.txt", :time => 120 },
                    { :name => "syslog in/json out", :config => "#{base_dir}/config/complex_syslog.conf", :input => "#{base_dir}/input/syslog_acl_10.txt", :time => 120} ]
end
