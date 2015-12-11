var App = App || {};

App.startupTimeChart = function (options) {
  if ( typeof options === 'undefined' ) { var options = {} }

  // Setup
  //
  var margin = { top:    options.top    || 10,
                 right:  options.right  || 20,
                 bottom: options.bottom || 10,
                 left:   options.left   || 5 },
      width  = options.width  || 320,
      height = options.height || 80;

  var x = d3.time.scale().range([0, width - margin.left - margin.right]);

  var y = d3.scale.linear().range([height - margin.top - margin.bottom, 0]);

  var yAxis = d3.svg.axis()
    .scale(y)
    .orient("right")
    .tickSize(5, 0)
    .ticks(4)
    .tickFormat(function(d) { return d3.format("s")(d) + 's'});

  var parameterize = function(s) {
    return s.toLowerCase().replace(/[^a-z0-9]/g, "-")
  };

  var aggregated_data = null;

  // Draw
  //
  var draw = function(svg, data) {
    var bar = svg.selectAll('line.bar')
        .data(data, function(d) { return d.time });

      bar.enter()
        .append("line")
          .attr('id', function(d,i) { return parameterize('startup-time-line-' + d.time) })
          .attr('class', 'bar');

      bar
        .attr('data-value', function(d) { return d.value})
        .transition()
        .duration(250)
        .ease('circle')
          .attr("y1", function(d) { return y(d.value) })
          .attr("x1", function(d) { return x(d.time) })
          .attr("x2", function(d) { return x(d.time) })
          .attr("y2", function(d) { return height-margin.bottom-margin.top });

      bar.exit()
        .remove();

    var label = svg.selectAll('g.label')
        .data(data, function(d) { return d.time });

        label.enter()
          .append('g')
            .attr('id', function(d,i) { return parameterize('startup-time-label-' + d.time) })
            .attr('class', 'label')
            .attr('transform', function(d) { return 'translate(' + x(d.time) + ', -5)' } )
            .append('text')

        label.exit()
          .remove()

    label.select('text').text(function(d) { return d.value + 's' });


    bar.on('mouseover', function(d,i) {
      chart.focus.call(this, d.time, i)
    });
    bar.on('mouseout', function(d,i) {
      chart.unfocus.call(this, d.time, i)
    });

    return this
  };

  // The main function

  var chart = function(selection) {
    var svg = selection
      .append('svg')
      .attr('width',  width + margin.left + margin.right)
      .attr('height', height + margin.top  + margin.bottom)
        .append('g')
          .classed('container', true)
          .attr("transform", "translate(" + (margin.left+margin.right) + "," + (margin.top + margin.bottom) + ")");

    selection.each(function(data) {
      var versions = data['datasets'].map( function(d) { return d.label } ).sort().reverse();

      var max = d3.max(data.datasets.map( function(d) { return d.data } ).reduce( function(a, b) { return a.concat(b) }));

      aggregated_data = data['labels'].map(function(d, i) {
        return {
          time:  d3.time.format("%Y-%m-%d").parse(d),
          value: d3.mean(data['datasets'].map( function(e) { return e['data'][i] }) )
        }
      });

      x.domain(d3.extent(data.labels, function(d) { return d3.time.format("%Y-%m-%d").parse(d) }));
      y.domain([0, max]);

      var legend = svg.append('g').attr('class', 'legend')
            .selectAll('g')
            .data(versions)
            .enter()
            .append('g')
            .classed('version', true)
            .attr('id', function(d) { return parameterize('legend-' + d) })
            .attr('transform', function(d, i) {
              switch(d) {
                case 'master':
                  var x = 0;
                  break;
                case '2.1':
                  var x = 50;
                  break;
                default:
                  var x = 50+11 + (i*11)+((i-2)*22)
              };
              var y = height-margin.bottom-5;

              return 'translate(' + x + ', ' + y + ')'
            });

          legend.append('rect')
            .attr('width', function(d) { return d == 'master' ? '2.8em' : d.length * 0.6 + 'em' })
            .attr('height', 14)
            .attr('rx', 5)
            .attr('ry', 5);

          legend.append('text')
            .attr('dx', '1.1em')
            .attr('dy', '1.25em')
            .text(function(d) { return d });

          legend.on('click', function(d) {
            if ( d3.select(this).classed('selected') ) {
              d3.select(this).classed('selected', false)
              draw(svg, aggregated_data)
            }

            else {
              d3.selectAll('.legend .version').classed('selected', false)
              d3.select(this).classed('selected', true)

              var dataset = data.datasets.filter( function(e) { return e.label == d } )[0];

              var dataset_normalized = data['labels'].map(function(date, i) {
                return {
                  time:  d3.time.format("%Y-%m-%d").parse(date),
                  value: dataset.data[i]
                }
              })

              draw(svg, dataset_normalized)
            }
          })

      svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + (width - margin.right - margin.left) + "," + 0 + ")")
        .call(yAxis);
      svg.select('.y.axis text').style('display', 'none'); // Hide bottom zero
      svg.select('.y.axis').attr('transform', 'translate(' + (width - margin.left - margin.right - 2) + ',3)') // Tighten the ticks a bit to the chart

      svg.append("line")
        .attr('x1', -1)
        .attr('x2', width-margin.left-margin.right+1)
        .attr('y1', height - margin.top - margin.bottom)
        .attr('y2', height - margin.top - margin.bottom)

      svg.append("text")
        .attr('x', width - margin.right - 3)
        .attr('y', height - margin.top + 5)
        .attr('class', 'chart-legend')
        .text('STARTUP TIME')

      draw(svg, aggregated_data)
    });
  };

  chart.focus = function(date, index) {
    var element = d3.select('#' + parameterize('startup-time-line-' + date));

    element.classed('over', true)
    d3.select( '#' + parameterize('startup-time-label-' + date) ).classed('over', true)

    return this
  };

  chart.unfocus = function(date, index) {
    var element = d3.select('#' + parameterize('startup-time-line-' + date));

    element.classed('over', false)
    d3.select( '#' + parameterize('startup-time-label-' + date) ).classed('over', false)

    return this
  }

  return chart;
};
