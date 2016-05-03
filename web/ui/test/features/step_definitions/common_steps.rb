When /^I load the application$/ do
  visit '/index.html'
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^save a screenshot$/ do
  page.driver.render "tmp/cucumber-#{@current_scenario_id};#{Time.now.to_i}.png"
end
