require 'test_helper'

require File.expand_path('../../lib/app/fetcher', __FILE__)

module Microsite

  class FetcherTest < MiniTest::Test
    context "Fetcher" do
      should "be initialized with a value" do
        assert_raises NameError do
          Microsite::Fetcher.new
        end

        assert_raises NameError do
          Microsite::Fetcher.new 'foobar'
        end

        Microsite::Fetcher.new 'events'
      end

      context "queries" do
        should "return query for events" do
          json = <<-JSON
          {
            "query":{
              "filtered":{
                "filter":{
                  "range":{
                    "@timestamp":{
                      "gte":"now-90d"
                    }
                  }
                }
              }
            },
            "size":0,
            "aggs":{
              "tests":{
                "terms":{
                  "field":"name.raw"
                },
                "aggs":{
                  "timestamps":{
                    "date_histogram":{
                      "field":"@timestamp",
                      "interval":"day",
                      "format":"yyyy-MM-dd"
                    },
                    "aggs":{
                      "versions":{
                        "terms":{
                          "field":"label.raw"
                        },
                        "aggs":{
                          "stats":{
                            "stats":{
                              "field":"events"
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          JSON

          fetcher = Microsite::Fetcher.new("events")

          fetcher.__send__(:client).expects(:search).with do |arguments|
            assert_equal MultiJson.load(json), MultiJson.load(MultiJson.dump(arguments[:body]))
          end

          fetcher.query
        end

        should "return query for start time" do
          json = <<-JSON
          {
            "query":{
              "filtered":{
                "filter":{
                  "range":{
                    "@timestamp":{
                      "gte":"now-90d"
                    }
                  }
                }
              }
            },
            "size":0,
            "aggs":{
              "timestamps":{
                "date_histogram":{
                  "field":"@timestamp",
                  "interval":"day",
                  "format":"yyyy-MM-dd"
                },
                "aggs":{
                  "test_cases":{
                    "terms":{
                      "field":"label.raw",
                      "size":10
                    },
                    "aggs":{
                      "stats":{
                        "stats":{
                          "field":"start time"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          JSON

          fetcher = Microsite::Fetcher.new("start_time")

          fetcher.__send__(:client).expects(:search).with do |arguments|
            assert_equal MultiJson.load(json), MultiJson.load(MultiJson.dump(arguments[:body]))
          end

          fetcher.query
        end

        should "return query for tests" do
          json = <<-JSON
          {
            "size":0,
            "aggs":{
              "series":{
                "terms":{
                  "field":"name.raw",
                  "size":10
                }
              }
            }
          }
          JSON

          fetcher = Microsite::Fetcher.new("tests")

          fetcher.__send__(:client).expects(:search).with do |arguments|
            assert_equal MultiJson.load(json), MultiJson.load(arguments[:body])
          end

          fetcher.query
        end

        should "return query for bundles" do
          json = <<-JSON
          {
            "size":0,
            "aggs":{
              "series":{
                "terms":{
                  "field":"label.raw",
                  "size":10
                }
              }
            }
          }
          JSON

          fetcher = Microsite::Fetcher.new("bundles")

          fetcher.__send__(:client).expects(:search).with do |arguments|
            assert_equal MultiJson.load(json), MultiJson.load(arguments[:body])
          end

          fetcher.query
        end
      end
    end
  end

end
