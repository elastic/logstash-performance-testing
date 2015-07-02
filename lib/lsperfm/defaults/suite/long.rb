# format description:
# each test can be executed by either target duration using :time => N secs
# or by number of events with :events => N
#
#[
#  {:name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :time => 30},
#  {:name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :events => 50000},
#]
#
[
  {:name => "simple line in/out", :config => "defaults/config/simple.conf", :input => "defaults/input/simple_10.txt", :time => 120},
  {:name => "simple line in/json out", :config => "defaults/config/simple_json_out.conf", :input => "defaults/input/simple_10.txt", :time => 120},
  {:name => "json codec in/out", :config => "defaults/config/json_inout_codec.conf", :input => "defaults/input/json_medium.txt", :time => 120},
  {:name => "line in/json filter/json out", :config => "defaults/config/json_inout_filter.conf", :input => "defaults/input/json_medium.txt", :time => 120},
  {:name => "apache in/json out", :config => "defaults/config/simple.conf", :input => "defaults/input/apache_log.txt", :time => 120},
  {:name => "apache in/grok codec/json out", :config => "defaults/config/simple_grok.conf", :input => "defaults/input/apache_log.txt", :time => 120},
  {:name => "syslog in/json out", :config => "defaults/config/complex_syslog.conf", :input => "defaults/input/syslog_acl_10.txt", :time => 120},
]
