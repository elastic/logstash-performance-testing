var options = {

  responsive: true,

  ///Boolean - Whether grid lines are shown across the chart
  scaleShowGridLines : true,

  //String - Colour of the grid lines
  scaleGridLineColor : "rgba(0,0,0,.05)",

  //Number - Width of the grid lines
  scaleGridLineWidth : 1,

  //Boolean - Whether to show horizontal lines (except X axis)
  scaleShowHorizontalLines: false,

  //Boolean - Whether to show vertical lines (except Y axis)
  scaleShowVerticalLines: false,

  //Boolean - Whether the line is curved between points
  bezierCurve : true,

  //Number - Tension of the bezier curve between points
  bezierCurveTension : 0.4,

  //Boolean - Whether to show a dot for each point
  pointDot : true,

  //Number - Radius of each point dot in pixels
  pointDotRadius : 4,

  //Number - Pixel width of point dot stroke
  pointDotStrokeWidth : 1,

  //Number - amount extra to add to the radius to cater for hit detection outside the drawn point
  pointHitDetectionRadius : 20,

  //Boolean - Whether to show a stroke for datasets
  datasetStroke : true,

  //Number - Pixel width of dataset stroke
  datasetStrokeWidth : 2,

  //Boolean - Whether to fill the dataset with a colour
  datasetFill : true,

  legendTemplate : '<ul class="legend">'
  +'<% for (var i=0; i<datasets.length; i++) { %>'
  +'<li style=\"background-color:<%=datasets[i].strokeColor%>\">'
  +'<% if (datasets[i].label) { %><%= datasets[i].label %><% } %>'
  +'</li>'
  +'<% } %>'
  +'</ul>',
  showTooltips: true,
  multiTooltipTemplate: "<%=datasetLabel%> : <%= value %>"
};

window.charts = {};

$.ajax({
  cache: false,
  url: "fetch_events.json",
  dataType: "json",
  success: function(data) {
    var ctx = document.getElementById("events-chart").getContext("2d");
    var eventsChart = new Chart(ctx).Line(data, options);
    var legend      = eventsChart.generateLegend();
    $('#events-placeholder').append(legend);
  }
});

$.ajax({
  cache: false,
  url: "fetch_tps.json",
  dataType: "json",
  success: function(data) {
    var ctx = document.getElementById("tps-chart").getContext("2d");
    var eventsChart = new Chart(ctx).Line(data, options);
    var legend      = eventsChart.generateLegend();
    $('#tps-placeholder').append(legend);
  }
});

$.ajax({
  cache: false,
  url: "fetch_elapsed.json",
  dataType: "json",
  success: function(data) {
    var ctx = document.getElementById("elapsed-chart").getContext("2d");
    var eventsChart = new Chart(ctx).Line(data, options);
    var legend      = eventsChart.generateLegend();
    $('#elapsed-placeholder').append(legend);
  }
});

$.ajax({
  cache: false,
  url: "fetch_starttime.json",
  dataType: "json",
  success: function(data) {
    var ctx = document.getElementById("starttime-chart").getContext("2d");
    var eventsChart = new Chart(ctx).Line(data, options);
    var legend      = eventsChart.generateLegend();
    $('#starttime-placeholder').append(legend);
  }
});

$.ajax({
  cache: false,
  url: "bundles.json",
  dataType: "json",
  success: function(data) {
    load_selector('#tps-version_selector', data);
    load_selector('#events-version_selector', data);
  }
});

$.ajax({
  cache: false,
  url: "tests.json",
  dataType: "json",
  success: function(data) {
    load_selector('#test-events-version_selector', data);
    load_selector('#test-tps-version_selector', data);
  }
});

function load_selector(selector, data) {
  $(selector).append('<option selected="selected"></option>');
  $.each(data, function (i, item) {
    $(selector).append($('<option>', {
      value: item.key,
      text : item.key
    }));
  });
}

function load_events(version) {
  $.ajax({
    cache: false,
    url: "fetch_events/"+version+".json",
    dataType: "json",
    success: function(data) {
      if (window.charts.events_label != undefined) {
        window.charts.events_label.destroy();
      }
      $("#label-events-chart").show();
      var ctx = document.getElementById("label-events-chart").getContext("2d");
      var eventsChart = new Chart(ctx).Line(data, options);
      var legend      = eventsChart.generateLegend();
      $('#test-events-placeholder').append(legend);
      window.charts.events_label = eventsChart;
    },
    error: function(data) {
      if (window.charts.events_label != undefined) {
        window.charts.events_label.destroy();
      }
      $("#label-events-chart").hide();
    }
  });
}

function load_events_by_test(test) {
  $.ajax({
    cache: false,
    url: "fetch_events/test/"+test+".json",
    dataType: "json",
    success: function(data) {
      if (window.charts.test_events_label != undefined) {
        window.charts.test_events_label.destroy();
      }
      $("#label-test-events-chart").show();
      $("#test-events-legend").show();
      $("#test-events-legend").empty();
      var ctx = document.getElementById("label-test-events-chart").getContext("2d");
      options['customTooltips'] =  function(tooltip) {

        // tooltip will be false if tooltip is not visible or should be hidden
        if (!tooltip) {
          return;
        }
        // Otherwise, tooltip will be an object with all tooltip properties like:
        var str = "<ul class='legend'>";
        str += "<li class='first'>"+tooltip.title+"</li>"
        for(var i=0; i < tooltip.labels.length; i++) {
          var v = tooltip.labels[i].split(":");
          if ( v[1] > 0 ) {
            str += "<li style='background-color:"+tooltip.legendColors[i].fill+"'>"+tooltip.labels[i]+"</li>"
          }
        }
        str += "</ul>"
        $("#test-events-legend").empty();
        $("#test-events-legend").append(str);
      }
      var eventsChart = new Chart(ctx).Line(data, options);
      window.charts.test_events_label = eventsChart;
    },
    error: function(data) {
      if (window.charts.test_events_label != undefined) {
        window.charts.test_events_label.destroy();
      }
      $("#label-test-events-chart").hide();
      $("#test-events-legend").hide();
    }
  });
}

function load_tps(version) {
  $.ajax({
    cache: false,
    url: "fetch_tps/"+version+".json",
    dataType: "json",
    success: function(data) {
      if (window.charts.tps_label != undefined) {
        window.charts.tps_label.destroy();
      }
      $("#label-tps-chart").show();
      var ctx = document.getElementById("label-tps-chart").getContext("2d");
      window.charts.tps_label = new Chart(ctx).Line(data, options);
    },
    error: function(data) {
      if (window.charts.tps_label != undefined) {
        window.charts.tps_label.destroy();
      }
      $("#label-tps-chart").hide();
    }
  });
}

function load_tps_per_test(test) {
  $.ajax({
    cache: false,
    url: "fetch_tps/test/"+test+".json",
    dataType: "json",
    success: function(data) {
      if (window.charts.test_tps_label != undefined) {
        window.charts.test_tps_label.destroy();
      }
      $("#label-test-tps-chart").show();
      $("#test-tps-legend").show();
      $("#test-tps-legend").empty();
      var ctx = document.getElementById("label-test-tps-chart").getContext("2d");
      options['customTooltips'] =  function(tooltip) {

        // tooltip will be false if tooltip is not visible or should be hidden
        if (!tooltip) {
          return;
        }
        // Otherwise, tooltip will be an object with all tooltip properties like:
        var str = "<ul class='legend'>";
        str += "<li class='first'>"+tooltip.title+"</li>"
        for(var i=0; i < tooltip.labels.length; i++) {
          var v = tooltip.labels[i].split(":");
          if ( v[1] > 0 ) {
            str += "<li style='background-color:"+tooltip.legendColors[i].fill+"'>"+tooltip.labels[i]+"</li>"
          }
        }
        str += "</ul>"
        $("#test-tps-legend").empty();
        $("#test-tps-legend").append(str);
      }
      window.charts.test_tps_label = new Chart(ctx).Line(data, options);
    },
    error: function(data) {
      if (window.charts.test_tps_label != undefined) {
        window.charts.test_tps_label.destroy();
      }
      $("#label-test-tps-chart").hide();
      $("#test-tps-legend").hide();
    }
  });
}

$(document).ready(function() {
  $("#label-test-events-chart").hide();
  $("#label-test-tps-chart").hide();
  $("#label-events-chart").hide();
  $("#label-tps-chart").hide();
 
  $( "#test-events-version_selector" ).change(function() {
    var test = $('#test-events-version_selector :selected').text();
    load_events_by_test(encodeURIComponent(test));
  });
  $( "#events-version_selector" ).change(function() {
    var version = $('#events-version_selector :selected').text();
    load_events(version);
  });

  $( "#test-tps-version_selector" ).change(function() {
    var test = $('#test-tps-version_selector :selected').text();
    load_tps_per_test(encodeURIComponent(test));
  });

  $( "#tps-version_selector" ).change(function() {
    var version = $('#tps-version_selector :selected').text();
    load_tps(version);
  });
})
