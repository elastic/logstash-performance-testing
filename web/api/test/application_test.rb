require 'test_helper'

require File.expand_path('../../lib/application', __FILE__)

module Microsite

  class ApplicationTest < MiniTest::Test
    include Rack::Test::Methods
    alias :response :last_response

    def app
      Application.new
    end

    context "Application" do
      setup do
        Microsite::Fetcher.stubs(:find_versions)
      end

      should "get the list of APIs" do
        get '/'
        assert response.ok?, response.status.to_s
        assert_match %r{http://example.org/events.json}, response.body
      end

      should "set the prefix for requests coming from Nginx" do
        get '/', {}, { 'HTTP_X_PROXY_CLIENT' => 'nginx' }
        assert_match %r{http://example.org/api/events.json}, response.body
      end

      should "set CORS headers for Ajax requests" do
        get '/', {}, { "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest" }

        assert last_request.xhr?
        assert response.ok?, response.status.to_s
        assert_equal '*', response.headers['Access-Control-Allow-Origin']
      end

      should "get events.json" do
        Microsite::Fetcher.expects(:fetch).with('events')

        Microsite::Decorator.expects(:as_event_list)
          .returns({
            "apache in/grok codec/json out" => \
              [{"time"=>"2015-10-08", "values"=>{"master"=>6417180.0, "1.5"=>2863740.0, "2.0"=>0, "2.1"=>0}}]
          })

        get '/events.json'
        assert response.ok?, response.status.to_s
        assert_match %r{"apache in/grok codec/json out"}, response.body
      end

      should "get startup_time.json" do
        Microsite::Fetcher.expects(:fetch).with('start_time')

        Microsite::Decorator.expects(:as_chart)
          .returns({
            "labels" => ["2015-09-23", "2015-09-24", "2015-12-18"],
            "datasets" => [ { "label" => "1.5", "data" => [ 3, 2, 1 ] } ]
          })

        get '/startup_time.json'
        assert response.ok?, response.status.to_s
        assert_match %r{"labels"}, response.body
        assert_match %r{"datasets"}, response.body
      end
    end

  end
end
