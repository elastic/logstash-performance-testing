var App = App || {}

App.matrixChart = function(json, options) {
  if ( typeof json    === 'undefined' ) { throw( new Error('The `json` argument is required')) };
  if ( typeof options === 'undefined' ) { var options = {} };

  var selection = options.selection || d3.select("#matrix-chart");

  var parameterize = function(s) {
        return s.toLowerCase().replace(/[^a-z0-9]/g, "-")
      };

  function focus(date) {
    var elements = selection.selectAll('.' + parameterize('matrix-chart-tick-' + date));
    elements.classed('over', true);

    return this
  };

  function unfocus(date) {
    var elements = selection.selectAll('.' + parameterize('matrix-chart-tick-' + date));
    elements.classed('over', false);

    return this
  };

  var draw = function() {
    var all_values = d3.values(json)
          .map(
            function(a) {
              return a.map( function(b) { return d3.values(b.values) } )
                      .reduce( function(i,j) { return i.concat(j) } ) } )
          .reduce( function(i,j) { return i.concat(j) } );

    var min  = d3.min(all_values);
    var max  = d3.max(all_values);
    var mean = Math.round(d3.mean(all_values));
    var median = Math.round(d3.median(all_values));

    for ( configuration in json ) {
      var data = {
        label: configuration,
        data:  json[configuration],
        min: min,
        max: max,
        mean: mean,
        median: median
      }
      draw_single(data)
    }

    return this
  };

  var draw_single = function(data) {
    selection.datum(data).call(area_chart);
  };

  var area_chart = function(selection, options) {
    selection.each(function(data) {
      // Setup
      var options = options || {}

      var margin = {
            top:    options.margin_top    || 20,
            right:  options.margin_right  || 20,
            bottom: options.margin_bottom || 20,
            left:   options.margin_left   || 20
          },
          width  = 235,
          height = 50;

      var x = d3.time.scale().range([0, width]);
      var y = d3.scale.linear().range([height, 0]);
      var xAxis = d3.svg.axis().scale(x).orient('bottom').tickSize(5, 0).ticks(d3.time.day, 1);
      var yAxis = d3.svg.axis().scale(y).orient('left').tickSize(5, 0).ticks(4).tickFormat(d3.format('s'));

      var area = d3.svg.area()
        .x(function(d) { return x(d.time); })
        .y0(height)
        .y1(function(d) { return y(d.mean); })
        .interpolate('basis');

      var svg = selection
        .append('div')
          .attr('id', function(d) { return parameterize('chart-' + d.label) })
          .attr('class', 'chart')
        .append('svg')
          .attr('width', width + margin.left + margin.right)
          .attr('height', height + margin.top + margin.bottom)
          .append('g')
            .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

      var label = data.label,
          name  = label.toUpperCase().replace(/\//g, ' / '),

          data_normalized = data.data.map( function(d, i) {
            var values = d3.values(d.values).filter(function(d) { return +d > 0})

            return {
              time:     d3.time.format('%Y-%m-%d').parse(d.time),
              values:   values,
              min:      data.min,
              max:      data.max,
              mean:     Math.round(d3.mean(values)),
              median:   data.median
            }
          });

      x.domain(d3.extent(data_normalized, function(d) { return d.time; })).ticks(d3.time.day, 1);
      y.domain([0, data.max]);

      // Draw

      svg.append('path')
        .datum(data_normalized)
        .attr('class', 'area')
        .attr('d', area);

      svg.append('g')
        .attr('class', 'y axis')
        .attr('transform', 'translate(0,' + x.range()[0] + ')')
        .call(yAxis);

      svg.select('.y.axis text').style('display', 'none'); // Hide bottom zero
      svg.selectAll('.y.axis .tick text').attr('x', '-5'); // Adjust tick text

      var tick = svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + x.range()[0] + ')')
        .call(xAxis)

      tick.selectAll('text').remove();    // Remove x-axis tick text
      tick.selectAll('.domain').remove(); // Remove x-axis domain

      tick.selectAll('.x.axis g.tick')
        .attr('class', function(d) { return 'tick ' + parameterize('matrix-chart-tick-' + d) })
        .append('line')
        .attr('y1', -12)
        .attr('y2', height)
        .classed('ruler', true);

      tick.selectAll('.x.axis g.tick')
        .append('rect')
        .attr('x', 0)
        .attr('y', 0)
        .attr('width', function(d) {
          tickArr = x.ticks()
          difference = x(tickArr[tickArr.length - 1]) - x(tickArr[tickArr.length - 2])
          return difference/7;
        })
        .attr('height', height)
        .classed('overlay', true)
        .style('opacity', 0);

      tick.selectAll('.x.axis g.tick')
        .append('text')
        .attr('class', 'label')
        .attr('dx', function(d) { return x(d) < width/2 ? 3 : -3 })
        .attr('dy', -6)
        .style('text-anchor', function(d) { return x(d) < width/2 ? 'start' : 'end' })
        .text(function(d,i) {
          var found = data_normalized.filter(function(e) { return d.getTime() == e.time.getTime() })[0]
          return found ? d3.format(',')(found.mean) : 'N/A'
        });

      svg.append('text')
        .attr('class', 'legend')
        .attr('x', width)
        .attr('y', height+13)
        .style('text-anchor', 'end  ')
        .text(name);

      svg.append('line')
        .attr('y1', function(d) { return y(d.median) })
        .attr('y2', function(d) { return y(d.median) })
        .attr('x1', 0)
        .attr('x2', width)
        .attr('stroke-dasharray', '1, 1')
        .classed('average', true);

      // Interactivity

      svg.selectAll('.x.axis g.tick .overlay')
        .on('mouseover', function(d, i) {
          focus.call(this, d)
          $(document).trigger('timeline.date.focus', d, i)
        })
        .on('mouseout', function(d, i)  {
          unfocus.call(this, d)
          $(document).trigger('timeline.date.unfocus', d, i)
        })

      selection.selectAll('div.chart')
        .on('click', function(d) {
          $(document).trigger('timeline.configuration.load', d.label)
        })
    })

    return this
  };

  return {
    json:    json,
    options: options,
    selection: selection,
    draw:    draw,
    focus:   focus,
    unfocus: unfocus
  }
};
