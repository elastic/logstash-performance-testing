require 'test/unit/assertions'
require 'cucumber'
require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'

Capybara.default_selector      = :css
Capybara.default_driver        = :poltergeist
Capybara.app_host              = 'http://localhost:8000'
Capybara.default_max_wait_time = 5
Capybara.run_server            = false

World(Test::Unit::Assertions)

Before do |scenario|
  @current_feature_id  = scenario.feature.name.downcase.gsub(/\s/, '-')
  @current_scenario_id = scenario.name.downcase.gsub(/\s/, '-')
end

After do |scenario|
  page.driver.render [File.expand_path('../../../tmp', __FILE__),
                     "#{@current_feature_id};FAILED.png"].join('/') if scenario.failed?
end
