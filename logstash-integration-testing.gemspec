# -*- encoding: utf-8 -*-
require File.expand_path('../lib/lsit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Pere Urbon-Bayes"]
  gem.email         = ["pere.urbon@elasticsearch.com"]
  gem.description   = %q{Logstash integration testing support made easy}
  gem.summary       = %q{lsit - Integration testing for Logstash}
  gem.homepage      = "http://logstash.net/"
  gem.license       = "Apache License (2.0)"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "lsit"
  gem.require_paths = ["lib"]
  gem.version       = LSit::VERSION

  gem.executables = ["lsit-suite", "lsit-deps"]

  gem.add_runtime_dependency "minitest"           #(MIT license) for running the tests from the jar,
  gem.add_runtime_dependency "rspec", "~> 2.14.0" #(MIT license)

end
