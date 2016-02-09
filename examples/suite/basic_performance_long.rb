# format description:
# each test can be executed by either target duration using :time => N secs
# or by number of events with :events => N
#
#[
#  {:name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :time => 30},
#  {:name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :events => 50000},
#]
#
TIME = 120
CONFIG_PATH = "examples/config/"
INPUT_PATH = "examples/input/"

[
  {:name => "simple line in/out", :config => "simple.conf", :input => "simple_10.txt", :time => TIME},
  {:name => "simple line in/json out", :config => "simple_json_out.conf", :input => "simple_10.txt", :time => TIME},
  {:name => "json codec in/out", :config => "json_inout_codec.conf", :input => "json_medium.txt", :time => TIME},
  {:name => "line in/json filter/json out", :config => "json_inout_filter.conf", :input => "json_medium.txt", :time => TIME},
  {:name => "apache in/json out", :config => "simple.conf", :input => "apache_log.txt", :time => TIME},
  {:name => "apache in/grok codec/json out", :config => "simple_grok.conf", :input => "apache_log.txt", :time => TIME},
  {:name => "syslog in/json out", :config => "complex_syslog.conf", :input => "syslog_acl_10.txt", :time => TIME},
].map do |test|
  test.merge({:config => CONFIG_PATH + test[:config], :input => INPUT_PATH + test[:input], :time => TIME})
end

