When /^I click the '(.+?)' link?$/ do |selector|
  page.find(selector).click
end

Then /^I should see (\d+) '(\S+)' elements?$/ do |number, selector|
  # assert_equal number.to_i, page.all(selector).size
  page.assert_selector selector, count: number
end

Then /^I should see the '(.+?)' element?$/ do |selector|
  assert page.find(selector).visible?, "Page doesn't show the '#{selector}' element"
end

Then /^I should see '(.+?)' on the page?$/ do |content|
  assert_text content
end
