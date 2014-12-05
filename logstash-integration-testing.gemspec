# -*- encoding: utf-8 -*-
require File.expand_path('../lib/lsit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Pere Urbon-Bayes"]
  gem.email         = ["pere.urbon@elasticsearch.com"]
  gem.description   = %q{Logstash integration testing support maked easy}
  gem.summary       = %q{lsit - Integration testing for Logstash}
  gem.homepage      = "http://logstash.net/"
  gem.license       = "Apache License (2.0)"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "lsit"
  gem.require_paths = ["lib"]
  gem.version       = LSit::VERSION

  gem.executables = ["lsit-suite", "lsit-deps"]

  gem.add_runtime_dependency "cabin", [">=0.6.0"] #(Apache 2.0 license)
  gem.add_runtime_dependency "minitest"           #(MIT license) for running the tests from the jar,
  gem.add_runtime_dependency "pry"                #(Ruby license)
  gem.add_runtime_dependency "stud"               #(Apache 2.0 license)
  gem.add_runtime_dependency "clamp"              #(MIT license) for command line args/flags

  gem.add_runtime_dependency "rspec", "~> 2.14.0" #(MIT license)
end
