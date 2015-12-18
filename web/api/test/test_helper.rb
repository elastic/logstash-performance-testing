require 'minitest/autorun'
require 'shoulda/context'
require 'mocha/setup'

require 'rack/test'

require 'sinatra'

ENV['RACK_ENV'] = 'test'
