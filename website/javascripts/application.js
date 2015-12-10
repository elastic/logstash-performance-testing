var App = App || {}

App.run = function() {
  App.__load_startup_time();

  return this;
}

App.__load_startup_time = function() {
  d3.json('data/startup_time.json', function(error, json) {
    if (error) return console.warn(error.responseText);

    d3.select('#startup-time-chart')
      .datum(json)
      .call(App.startupTimeChart())
  });
}
