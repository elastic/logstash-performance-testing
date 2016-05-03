require 'test_helper'

require File.expand_path('../../lib/app/fetcher', __FILE__)

module Microsite

  class FetcherTest < MiniTest::Test

    def assert_same_hash(a, b, m=nil)
      a = a.is_a?(String) ? MultiJson.load(a) : MultiJson.load(MultiJson.dump(a.to_hash))
      b = b.is_a?(String) ? MultiJson.load(b) : MultiJson.load(MultiJson.dump(b.to_hash))
      assert_equal a, b, m
    end

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

            "aggregations":{
              "tests":{
                "terms":{
                  "field":"name.raw"
                },
                "aggregations":{
                  "timestamps":{
                    "date_histogram":{
                      "field":"@timestamp",
                      "interval":"day",
                      "format":"yyyy-MM-dd"
                    },
                    "aggregations":{
                      "versions":{
                        "terms":{
                          "field":"label.raw"
                        },
                        "aggregations":{
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
            },

            "size":0
          }
          JSON

          fetcher = Microsite::Fetcher.new("events")

          fetcher.__send__(:client).expects(:search).with do |arguments|
            assert_same_hash json, arguments[:body]
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

            "aggregations":{
              "timestamps":{
                "date_histogram":{
                  "field":"@timestamp",
                  "interval":"day",
                  "format":"yyyy-MM-dd"
                },
                "aggregations":{
                  "test_cases":{
                    "terms":{
                      "field":"label.raw",
                      "size":10
                    },
                    "aggregations":{
                      "stats":{
                        "stats":{
                          "field":"start time"
                        }
                      }
                    }
                  }
                }
              }
            },

            "size":0
          }
          JSON

          fetcher = Microsite::Fetcher.new("start_time")

          fetcher.__send__(:client).expects(:search).with do |arguments|
            assert_same_hash json, arguments[:body]
          end

          fetcher.query
        end

        should "return query for tests" do
          json = <<-JSON
          {
            "aggregations":{
              "series":{
                "terms":{
                  "field":"name.raw",
                  "size":10
                }
              }
            },
            "size":0
          }
          JSON

          fetcher = Microsite::Fetcher.new("tests")

          fetcher.__send__(:client).expects(:search).with do |arguments|
            assert_same_hash json, arguments[:body]
          end

          fetcher.query
        end

        should "return query for bundles" do
          json = <<-JSON
          {
            "aggregations":{
              "series":{
                "terms":{
                  "field":"label.raw",
                  "size":10
                }
              }
            },
            "size":0
          }
          JSON

          fetcher = Microsite::Fetcher.new("bundles")

          fetcher.__send__(:client).expects(:search).with do |arguments|
            assert_same_hash json, arguments[:body]
          end

          fetcher.query
        end
      end
    end
  end

end
