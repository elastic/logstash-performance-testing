# format description:
# each test can be executed by either target duration using :time => N secs
# or by number of events with :events => N
#
# you can specify the number of filter worker threads for each test with :workers => N
# if you don't specify workers, it defaults to 1
#
#[
#  {:name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :time => 30},
#  {:workers => 2, :name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :events => 50000},
#]
#
# We use 2 workers here as an example, since most machines can handle that, but machines with more CPUs can handle more threads.
[
  {:name => "simple line in/out", :config => "config/simple.conf", :input => "input/simple_10.txt", :time => 120},
  {:workers => 2, :name => "simple line in/json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :time => 120},
  {:name => "json codec in/out", :config => "config/json_inout_codec.conf", :input => "input/json_medium.txt", :time => 120},
  {:workers => 2, :name => "line in/json filter/json out", :config => "config/json_inout_filter.conf", :input => "input/json_medium.txt", :time => 120},
  {:name => "apache in/json out", :config => "config/simple.conf", :input => "input/apache_log.txt", :time => 120},
  {:workers => 2, :name => "apache in/grok codec/json out", :config => "config/simple_grok.conf", :input => "input/apache_log.txt", :time => 120},
  {:name => "syslog in/json out", :config => "config/complex_syslog.conf", :input => "input/syslog_acl_10.txt", :time => 120},
]
