# Logstash benchmarks API

This application provides an HTTP API for the continuous benchmarks
for the [Logstash](https://www.elastic.co/products/logstash) project.

## Endpoints

* `events.json` returns information about the throughput for each measured version and configuration

* `startup_time.json` returns information about the startup time for each measured version

## Configuration

Export the `ELASTICSEARCH_URL` variable to point to the Elasticsearch cluster containing
the saved measurements.

-----

(c) 2014 Elastic.co
