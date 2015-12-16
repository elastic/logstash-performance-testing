Feature: Displaying the dashboard

  Scenario: Displaying the dashboard
    When I load the application
    Then I should see 9 'svg' elements
    And I should see the '#startup-time-chart svg' element
    And I should see the '#main-chart svg' element
    And I should see the '#matrix-chart .chart:first-child svg' element

  Scenario: Loading a configuration
    When I load the application
    And I click the '#chart-apache-in-json-out' link
    Then I should see the '#loaded-configuration strong' element
    And I should see 'apache in/json out' on the page
