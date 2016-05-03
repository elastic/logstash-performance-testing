# Logstash benchmarks API

This application provides an HTTP API for the continuous benchmarks
for the [Logstash](https://www.elastic.co/products/logstash) project.

## Endpoints

* `events.json` returns information about the throughput for each measured version and configuration

* `startup_time.json` returns information about the startup time for each measured version

## Configuration

Export the `ELASTICSEARCH_URL` variable to point to the Elasticsearch cluster containing
the saved measurements.

You can configure the `Microsite::Runner` class with environment variables as well:

* LSPERF_RUNNER_RELEASES
* LSPERF_RUNNER_BRANCHES
* LSPERF_RUNNER_WORKSPACE
* LSPERF_RUNNER_REPO
* LSPERF_RUNNER_RUBY
* LSPERF_RUNNER_GEMSET
* LSPERF_RUNNER_SETUP

-----

(c) 2014 Elastic.co
