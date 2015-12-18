var App = App || {}

App.run = function() {

  if (document.location.host == 'localhost:8000') {
    App.host = './data/'
  } else {
    App.host = '/api/'
  }

  var configuration = decodeURIComponent( document.location.hash.substr(document.location.hash.indexOf('#')+1) );

  App.__load_startup_time();
  App.__load_main_chart(configuration);
  App.__load_matrix_chart(configuration);

  App.Dispatcher();

  if ( configuration.length > 0 ) {
    $('#loaded-configuration').html('Showing the <strong>' + configuration + '</strong> configuration.')
  } else {
    $('#loaded-configuration').html('<small>Showing aggregated values acrross all configurations — click one of the smaller charts below to display a specific configuration.</small>')
  }

  return this;
}

App.parameterize = function(s) {
  return s.toLowerCase().replace(/[^a-z0-9]/g, "-")
};

App.__load_startup_time = function() {
  d3.json(App.host + 'startup_time.json', function(error, json) {
    if (error) return console.warn(error.responseText);

    App.startup_time_chart = App.startupTimeChart();
    d3.select('#startup-time-chart').datum(json).call(App.startup_time_chart)
  });
}

App.__load_main_chart = function(configuration) {
  d3.json(App.host + 'events.json', function(error, json) {
    App.main_chart = App.timeLineChart(json, { container: d3.select("#main-chart") });
    App.main_chart.draw(configuration)
  });
  return this
}

App.__load_matrix_chart = function(configuration) {
  d3.json(App.host + 'events.json', function(error, json) {
    App.matrix_chart = App.matrixChart(json);
    App.matrix_chart.draw(configuration)
    if (configuration.length > 0) {
      App.matrix_chart.selection.select( '#chart-' + App.parameterize(configuration) ).classed('selected', true)
    }
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

  $(document).on('timeline.configuration.load', function(event, name) {
    App.main_chart.draw(name)
    App.matrix_chart.selection.selectAll('.chart').classed('selected', false)
    App.matrix_chart.selection.select( '#chart-' + App.parameterize(name) ).classed('selected', true)

    $('#loaded-configuration').html('Showing the <strong>' + name + '</strong> configuration.')

    document.location.hash = encodeURIComponent(name)
  })

  return this
};
