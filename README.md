# Performance Testing for Logstash

## Installation

You can use this code as a gem within your logstash project, to proceed with the installation you can either download the code and build the gem using the next command:

To run a benchmark using the Logstash Performance meter tool you will need to install this gem in your system, and to do it you can run the next command:

* ```gem install logstash-perftool```

This will make the last version of this gem available to you.

or, if you like to be on the edge, you can add it to your Gemfile like this:

    gem 'logstash-perftool', :git => 'https://github.com/elastic/logstash-performance-testing.git'

and then do budler update.

## Setup and Runtime

The most simple scenario you could find is using the default set of
test, available in this gem. To do this you can simple run the ```lsperfm```
from the root of your Logstash installation.

If you like to add you own configurations and test suites,  you needuthe next data (you can see an example of them at the `examples/` directory):

- The logstash configs, found in `..config/`
- The sample input files, found in `..input/`
- The suites definitions, found in `..suite/`

### Configuration

If you add a file named ```.lsperfm.yml``` in your main logstash directory you can have your configuration and input files in non standard
location.

Example:

```
default:
  path: 'config-path'
  config: ''
  input: ''
```

### Bootstrap

Before you can run your test is necessary to bootstrap your logstash installation and install the test dependencies, to do that you must:

If you are in 1.5.x:
- Run `rake bootstrap` to setup the system.
- Run `lsperfm-deps` to install the test dependencies
For 1.4:
- Run `bin/logstash deps` to setup everything.

## Performance tests

The test are run in groups called suites.

### How to execute the default tests

This is the most simple use case you can have. To run the default tests
you can simply run ```lsperfm``` from the root of your Logstash
installation and the tool will use the default test suite.

### How to run a custom test suite

- suites examples can be found in `examples/suite/`

```
lsperfm [suite definition]
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

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports,
complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and
maintainers or community members  saying "send patches or die" - you will not
see that here.

It is more important to me that you are able to contribute.

### Contribution Steps

1. Test your changes! Write test and run the test suites.t s
2. Please make sure you have signed our [Contributor License
   Agreement](http://www.elastic.co/contributor-agreement/). We are not
   asking you to assign copyright to us, but to give us the right to distribute
   your code without restriction. We ask this of all contributors in order to
   assure our users of the origin and continuing existence of the code. You
   only need to sign the CLA once.
3. Send a pull request! Push your changes to your fork of the repository and
   [submit a pull
   request](https://help.github.com/articles/using-pull-requests). In the pull
   request, describe what your changes do and mention any bugs/issues related
   to the pull request.
