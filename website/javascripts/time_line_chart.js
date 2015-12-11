var App = App || {};

App.timeLineChart = function(json, options) {
  if ( typeof json    === 'undefined' ) { throw( new Error('The `json` argument is required')) };
  if ( typeof options === 'undefined' ) { var options = {} }

  var container = options.container || d3.select("#chart"),

      margin = { top:    options.top || 40,
                 right:  options.right || 120,
                 bottom: options.bottom || 60,
                 left:   options.left ||40 },
      width  = options.width || 1300,
      height = options.height || 400,

      xValue = function(d) { return d[0]; },
      yValue = function(d) { return d[1]; },

      xScale = d3.time.scale(),
      yScale = d3.scale.linear(),

      xAxis  = d3.svg.axis().scale(xScale).orient("bottom").tickSize(5, 0).ticks(d3.time.day, 1),
      yAxis  = d3.svg.axis().scale(yScale).orient("left").tickSize(5, 0).ticks(10).tickFormat(d3.format("s")),

      color = d3.scale.ordinal().range(['#7ec700', '#146655', '#1f9981', '#29ccab', '#33ffd6']),

      line   = d3.svg.line().interpolate('basis').x(function(d) { return xScale(d.time)}).y(function(d) { return yScale(d.value)}),

      parameterize = function(s) {
        return s.toLowerCase().replace(/[^a-z0-9]/g, "-")
      };

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

    // Aggregate data for the default view (no configuration selected)
    //
    var aggregated_data = function() {
      var aggregated_data = json[d3.keys(json)[0]].map( function(d) { return { time: d.time, values: {}, __values: [] } } )

      aggregated_data.forEach( function(d, i) {
        for ( configuration in json ) {
          var data = json[configuration].find( function(e) { return e.time == d.time } );
          // console.log(d.time, configuration, data.values);
          d.__values.push(data.values)
        }
      })

      aggregated_data.forEach( function(d, i) {
        d.__values.reduce( function(a, b) {
          for (var prop in b) {
            if (!a[prop]) { d.values[prop] = [] };
            d.values[prop].push(b[prop])  };
            return d.values;
        }, {} )
      })

      aggregated_data.forEach( function(d, i) {
        for ( var version in d.values ) {
          var mean = Math.round(d3.mean(d.values[version]));
          d.values[version] = mean
        }
      })

      return aggregated_data;
    }

  function draw(configuration) {
    container.datum(
      configuration ? json[configuration] : aggregated_data()
    ).call(line_chart);
    return this
  };

  function focus(date) {
    var element = container.select('#' + parameterize('timeline-tick-' + date));

    if ( element.classed('locked') ) { return }

    element.select('.ruler').classed('off', false)
    container.select('#' + parameterize('label-' + date)).classed('off', false)
    element.select('.ruler').classed('on', true)
    container.select('#' + parameterize('label-' + date)).classed('on', true)

    return this
  }

  function unfocus(date) {
    var element = container.select('#' + parameterize('timeline-tick-' + date));

    if ( element.classed('locked') ) { return }

    element.select('.ruler').classed('off', true)
    container.select('#' + parameterize('label-' + date)).classed('off', true)
    element.select('.ruler').classed('on', false)
    container.select('#' + parameterize('label-' + date)).classed('on', false)

    return this
  }

  // The main function
  //
  function line_chart(selection) {
    selection.each(function(data) {
      // Normalize and manipulate the data
      //
      // 1. Convert date strings to time
      data = data.map( function(d) { return { time: d3.time.format("%Y-%m-%d").parse(d.time), values: d.values } });

      // 2. Replace 0s with previous value, to disable "dips" in the chart
      data = data.map(function(d, i) {
          for (prop in d.values) {
             if (d.values[prop] === 0 && data[i-1] && data[i-1].values[prop]) {
               d.values[prop] = data[i-1].values[prop]
             }
          }
          return d
      });

      var times  = data.map( function(d) { return d.time } ),
          values = data.map( function(d) { return d.values } );

      xScale
        .domain(d3.extent(times))
        .range([0, width - margin.left - margin.right]).nice(d3.time.day);

      yScale
        .domain([0, max])
        .range([height - margin.top - margin.bottom, 0]);

      color
        .domain(d3.keys(data[0].values).sort().reverse());

      var tick_width = function() {
        tickArr = xScale.ticks()
          difference = xScale(tickArr[tickArr.length - 1]) - xScale(tickArr[tickArr.length - 2])
          return Math.round((difference/7)+0.25)
        }()

      // TEMP: Remove old containers
      selection.selectAll('div.labels').remove()
      selection.selectAll('svg').remove()

      // [1] Labels
      var labels = selection
        .append('div')
        .attr('class', 'labels')
        .style({top: (margin.top+3)+'px', left: (margin.left+3)+'px'})

      // [2] Chart
      var svg = selection.append('svg');
      svg.attr('width', width)
         .attr('height', height)
         .append('g').classed('container', true);

      // [3] Container
      var container = svg.select('g.container')
            .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

      container.append('g').attr('class', 'y axis')
      container.append('g').attr('class', 'x axis')
      container.append('g').attr('class', 'lines-dimmed')
      container.append('g').attr('class', 'lines')
      container.append('g').attr('class', 'lines-dotted')
      container.append('g').attr('class', 'legend')

      // [4] Line charts
      var versions = color.domain().sort().map(function(name) {
        return {
          name: name,
          values: data.map(function(d) {
            return {time: d.time, value: d.values[name]};
          })
        };
      });

      // a. Clipping paths
      var existing_values = color.domain().map(function(version) {
          var dates = xScale.ticks(d3.time.day, 1).filter(function(d) {
            var found = data.filter(function(e) { return e.time.getTime() == d.getTime() })[0];
            var zero  = found ? +found.values[version] < 1 : null
            return !!found && !!!zero
          })
          return { version: version, dates: dates }
        })

      var clips = container
        .append('g')
        .attr('class', 'clips existing')

      var clip = clips
            .selectAll('clipPath')
            .data(existing_values)
            .enter()
            .append('clipPath')
            .attr('id', function(d) { return 'clip-existing-' + d.version });

          clip.selectAll('rect')
            .data(function(d) { return d.dates})
            .enter()
            .append('rect')
              .attr('width', tick_width)
              .attr('height', height-margin.top)
              .attr('x', function(d) { return xScale(d) })
              .attr('y', -margin.bottom)
              .attr('fill', 'yellow')
              .style('opacity', 0.1);

      var missing_values = color.domain().map(function(version) {
          var dates = xScale.ticks(d3.time.day, 1).filter(function(d) {
            var found = data.filter(function(e) { return e.time.getTime() == d.getTime() })[0];
            var zero  = found ? +found.values[version] < 1 : null
            return !!!found || !!zero
          })
          return { version: version, dates: dates }
        })

      var clips = container
        .append('g')
        .attr('class', 'clips')

      var clip = clips
            .selectAll('clipPath')
            .data(missing_values)
            .enter()
            .append('clipPath')
            .attr('id', function(d) { return 'clip-' + d.version });

          clip.selectAll('rect')
            .data(function(d) { return d.dates})
            .enter()
            .append('rect')
              .attr('width', tick_width)
              .attr('height', height-margin.top)
              .attr('x', function(d) { return xScale(d) })
              .attr('y', -margin.bottom)
              .attr('fill', 'yellow')
              .style('opacity', 0.1);

      // b. Dimmed lines (1px grey)
      container.select('g.lines-dimmed').selectAll('g')
          .data(versions)
        .enter()
        .append('g')
          .attr('id', function(d) { return parameterize('line-dimmed-' + d.name) })
          .attr('class', 'line dimmed')
          .append('path')
            .attr('d', function(d) { return line(d.values) })
            .attr('opacity', '0')
            .transition()
            .duration(500)
              .attr('opacity', '1');

      // c. Solid line charts
      var version = container.select('g.lines').selectAll('g')
          .data(versions)
        .enter().append('g')
          .attr('id', function(d) { return parameterize('line-' + d.name) })
          .attr('class', 'line');

      version
        .append('path')
          .attr('clip-path', function(d) { return 'url(#clip-existing-' + d.name + ')' })
          .style('stroke', function(d) { return color(d.name) })
          .attr('d', function(d) { return line(d.values) })
          .attr('opacity', '0')
          .transition()
          .duration(500)
            .attr('opacity', '1');

      // d. Dotted line charts
      container.select('g.lines-dotted').selectAll('g.line-dotted')
          .data(versions)
        .enter().append('g')
          .attr('class', 'line dotted')
          .attr('id', function(d) { return parameterize('line-dotted-' + d.name) })
          .append('path')
            .attr('clip-path', function(d) { return 'url(#clip-' + d.name + ')' })
            .attr('d', function(d) { return line(d.values) })
            .attr('stroke-dasharray', '2, 4')
            .style('stroke', function(d) { return color(d.name) })
            .attr('opacity', '0')
            .transition()
            .duration(500)
              .attr('opacity', '1');

      // [5] Series legends
      var legend = container.select('g.legend')
            .selectAll('g')
            .data(color.domain().sort())
            .enter()
            .append('g')
            .classed('series legend', true)
            .attr('id', function(d) { return parameterize('legend-' + d) })
            .attr('transform', function(d, i) {
              return 'translate('
                + ( width-margin.left-margin.right+15 )
                + ', '
                + ( (height-margin.top-margin.bottom-20) - i*25 )
                + ')'
            });

          legend.append('rect')
            .attr('width', function(d) { return d.length * 0.75 + 'em' })
            .attr('height', 20)
            .attr('rx', 10)
            .attr('ry', 10)
            .attr('style', function(d) { return 'fill:' + color(d) });

          legend.append('text')
            .attr('dx', '1.1em')
            .attr('dy', '1.25em')
            .style('fill', '#fff')
            .text(function(d) { return d });

      // [6] X-Axis
      container.select(".x.axis")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .call(xAxis)
       .selectAll('text')
          .attr("transform", "rotate(-90) translate(-10,-11)")
          .style('text-anchor', 'end')
          .style('font-weight', function(d) { return d.getDate() == 1 ? 'bolder' : 'normal' });

      container.selectAll('.x.axis g.tick')
        .attr('id', function(d) { return parameterize('timeline-tick-'+d) })
        .append('line')
          .attr('id', function(d) { return parameterize('ruler-'+d) })
          .attr('y1', -height-margin.top)
          .attr('y2', 0)
          .classed('ruler', true);
      container.selectAll('.x.axis g.tick')
        .append('rect')
          .attr('x', -5)
          .attr('y', -(height-margin.top-margin.bottom))
          .attr('width', function(d) {
            tickArr = xScale.ticks()
            difference = xScale(tickArr[tickArr.length - 1]) - xScale(tickArr[tickArr.length - 2])
            return difference/7;
          })
          .attr('height', height+margin.bottom)
          .classed('overlay', true)
          .style('opacity', 0);

      // [7] Y-Axis
      container.select(".y.axis")
          .attr("transform", "translate(0," + xScale.range()[0] + ")")
          .call(yAxis);
      container.select('.y.axis text').style({display: 'none'}); // Hide bottom zero

      container.selectAll('.y.axis g.tick')
        .append('line')
        .attr('x2', width-margin.left-margin.right)
        .attr('y2', 0)
        .classed('ruler', true)

      // [8] Labels
      var label = labels.selectAll('div').data(data)
        .enter()
        .append('div')
          .attr('id', function(d) { return parameterize('label-' + d.time) })
          .classed('label', true)
          .classed('off', true)
          .style('left', function(d) {
            var position = Math.round(xScale(d.time))
            if (position > width/2) { position = width - (width - position) - 500 - 10  }
            return position +'px'
          })
          .style('text-align', function(d) {
            var position = Math.round(xScale(d.time)-4)
            return (position > width/2) ? 'right' : 'left'
          })

          label.append('p')
            .classed('date', true)
            .attr('style', function(d) {
              var position = Math.round(xScale(d.time))
              if (position > width/2) {
                return 'right:-59px'
              } else {
                return 'left:-1em'
              }
            })
            .html(function(d) { return d3.time.format('%b %d')(d.time) })

          label.append('p')
            .classed('metrics', true)
            .html(function(d) {
              var result = []
              d3.keys(d.values).sort().reverse().forEach( function(version) {
                result.push(
                  '<span class="metric '+ parameterize('metric-'+version) +'">'
                      + '<span class="version" '
                      + 'style="background-color: ' + color(version) + '">'
                      + version
                      + '</span>'
                      + '<span class="value">'
                      + d3.format(',')(d.values[version])
                      + '</span>'
                  + '</span>'
                )
              })
              return result.join('\n')
            });

      var missing_dates = xScale.ticks(d3.time.day, 1).filter(function(d) {
                  return !!! data.filter(function(e) { return e.time.getTime() == d.getTime() })[0];
                })

      var label_missing = labels.selectAll('div.missing').data(missing_dates)
        .enter()
        .append('div')
          .attr('id', function(d) { return parameterize('label-' + d) })
          .classed('label missing', true)
          .classed('off', true)
          .style('left', function(d) {
            var position = Math.round(xScale(d))
            if (position > width/2) { position = width - (width - position) - 500 - 10  }
            return position +'px'
          })
          .style('text-align', function(d) {
            var position = Math.round(xScale(d)-4)
            return (position > width/2) ? 'right' : 'left'
          })

          label_missing.append('p')
            .classed('date', true)
            .attr('style', function(d) {
              var position = Math.round(xScale(d))
              if (position > width/2) {
                return 'right:-59px'
              } else {
                return 'left:-1em'
              }
            })
            .html(function(d) { return d3.time.format('%b %d')(d) })

          label_missing.append('p')
            .classed('metrics', true)
            .html('<span class="missing">N/A</span>');

      // Interactivity
      container.selectAll('.x.axis g.tick .overlay')
        .on('mouseover', function(d, i) {
          focus.call(this, d)
          $(document).trigger('timeline.date.focus', d, i)
        })
        .on('mouseout', function(d, i) {
          unfocus.call(this, d)
          $(document).trigger('timeline.date.unfocus', d, i)
        })
        .on('click', function(d)  {
          var tick = d3.select(this.parentNode)

          if ( tick.classed('locked') ) {
            tick.classed('locked', false)
            selection.select('#' + parameterize('label-' + d)).classed('locked', false)
            return this
          }

          tick.classed('locked', true)
          selection.select('#' + parameterize('label-' + d)).classed('locked', true)
        });

      legend.on('click', function(d) {
        if (
          !d3.select(this).classed('dimmed') &&
          d3.selectAll('.series.legend')[0].some( function(d) { return d3.select(d).classed('dimmed') } )
        )
          // Toggle: Reset the line charts
          {
            d3.selectAll('.series.legend').classed('dimmed', false)
            d3.selectAll('.lines .line').classed('on', false)
            d3.selectAll('.lines .line').classed('off', false)
            d3.selectAll('.lines-dotted .line').classed('on', false)
            d3.selectAll('.lines-dotted .line').classed('off', false)

            d3.selectAll('.lines .line').classed('highlighted', false)
            d3.selectAll('.lines-dotted .line').classed('highlighted', false)

            d3.selectAll('.series.readout').classed('on', false)
            d3.selectAll('.series.readout').classed('off', true)

            d3.selectAll('.metrics .metric').classed('off', false)
            d3.selectAll('.metrics .metric').classed('on',  false)
        } else
          // Highlight corresponding line chart
          {
            d3.selectAll('.series.legend').classed('dimmed', true)
            d3.select(this).classed('dimmed', false)

            d3.selectAll('.lines .line').classed('off', true)
            d3.selectAll('.lines-dotted .line').classed('off', true)

            d3.select('#line-'+parameterize(d)).classed('off', false)
            d3.select('#line-'+parameterize(d)).classed('on', true)
            d3.select('#line-'+parameterize(d)).classed('highlighted', true)

            d3.select('#line-dotted-'+parameterize(d)).classed('off', false)
            d3.select('#line-dotted-'+parameterize(d)).classed('on', true)
            d3.select('#line-dotted-'+parameterize(d)).classed('highlighted', true)

            d3.select('#readout-'+parameterize(d)).classed('off', false)
            d3.select('#readout-'+parameterize(d)).classed('on', true)

            d3.selectAll('.metrics .metric').classed('off', true)
            d3.selectAll('.metrics .' + parameterize('metric-'+d)).classed('off', false)
            d3.selectAll('.metrics .' + parameterize('metric-'+d)).classed('on', true)
        }
      })

    });
  };

  return {
    json:    json,
    options: options,
    draw:    draw,
    focus:   focus,
    unfocus: unfocus,
  };
}
