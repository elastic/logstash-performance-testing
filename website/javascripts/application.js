var App = App || {}

App.run = function() {
  App.__load_startup_time();
  App.__load_main_chart();
  App.__load_matrix_chart();

  App.Dispatcher();

  return this;
}

App.__load_startup_time = function() {
  d3.json('data/startup_time.json', function(error, json) {
    if (error) return console.warn(error.responseText);

    App.startup_time_chart = App.startupTimeChart();
    d3.select('#startup-time-chart').datum(json).call(App.startup_time_chart)
  });
}

App.__load_main_chart = function() {
  d3.json('data/events.json', function(error, json) {
    App.main_chart = App.timeLineChart(json, { container: d3.select("#main-chart") });
    App.main_chart.draw()
  });
  return this
}

App.__load_matrix_chart = function() {
  d3.json('data/events.json', function(error, json) {
    App.matrix_chart = App.matrixChart(json);
    App.matrix_chart.draw()
  });
}

App.Dispatcher = function(params) {
  $(document).on('timeline.date.focus', function(event, date, index) {
    App.startup_time_chart.focus(date, index)
    App.main_chart.focus(date, index)
    App.matrix_chart.focus(date, index)
  })

  $(document).on('timeline.date.unfocus', function(event, date, index) {
    App.startup_time_chart.unfocus(date, index)
    App.main_chart.unfocus(date, index)
    App.matrix_chart.unfocus(date, index)
  })

  return this
};
