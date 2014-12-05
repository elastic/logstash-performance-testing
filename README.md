# Integration Testing for Logstash

## Installation

You can use this code as gem within your logstash project, to procced with the installation you can either download the code and build the gem using the next command:

```gem install [path to the gemspec file]```

or add it to your Gemfile like this:

    gem 'lsit', :git => 'https://github.com/elasticssarch/logstash-integration-testing.git'

and then do budler update.

## Setup

To run the test you need to next data (you can see an example of them at the `examples/` directory):

- The logstash configs, found in `..config/`
- The sample input files, found in `..input/`
- The suites definitions, found in `..suite/`

### Bootstrap

Before you can run your test is necessary to bootstrap your logstash installation and install the test dependencies, to do that you must:

If you are in 1.5:
- Run `rake bootstrap` to setup the system.
- Run `lsit-deps` to install the test dependencies
For 1.4:
- Run `bin/logstash deps` to setup everything.

## Performance tests

Test can be run in groups of suites.

### How to run test suites

- suites examples can be found in `examples/suite/`

```
lsit-suite [suite definition]
```

a suite file defines a series of tests to run.

#### suite file format

```ruby
# each test can be executed by either target duration using :time => N secs
# or by number of events with :events => N
#
#[
#  {:name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :time => 30},
#  {:name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :events => 50000},
#]
#
[
  {:name => "simple json out", :config => "config/simple_json_out.conf", :input => "input/simple_10.txt", :time => 60},
  {:name => "simple line out", :config => "config/simple.conf", :input => "input/simple_10.txt", :time => 60},
  {:name => "json codec", :config => "config/json_inout_codec.conf", :input => "input/json_medium.txt", :time => 60},
  {:name => "json filter", :config => "config/json_inout_filter.conf", :input => "input/json_medium.txt", :time => 60},
  {:name => "complex syslog", :config => "config/complex_syslog.conf", :input => "input/syslog_acl_10.txt", :time => 60},
]
```
