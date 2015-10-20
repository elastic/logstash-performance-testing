module Microsite
  module QueryBuilder

    def self.filtered_query(options={})
      query = { query: {
        filtered: {
          filter: filter_range(options[:gte])[:filter]
        }
      }}
      if options[:field] && options[:value]
        query[:query][:filtered][:query] = query_match(options[:field], options[:value])
      end
      query
    end

    def self.query_match(field, value)
      { match: {
        field => value
      }}
    end

    def self.filter_range(gte)
      { filter: {
        range: {
          "@timestamp" => {
            gte: gte
          }
        }
      }}
    end

    def self.agggreation(term_field, stats_field)
      { aggs: {
        test_cases: {
          terms: {
            field: term_field,
            size: 10
          },
          aggs: {
            stats: {
              stats: {
                field: stats_field
              }
            }
          }
        }
      }}
    end

    def self.histogram
      { aggs: {
        timestamps: {
          date_histogram: {
            field: "@timestamp",
            interval: "day"
          }
        }
      }}
    end
  end
end
