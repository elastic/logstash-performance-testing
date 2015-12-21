require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'shoulda/context'
require 'mocha/setup'

require 'rack/test'

require 'sinatra'

ENV['RACK_ENV'] = 'test'

require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
