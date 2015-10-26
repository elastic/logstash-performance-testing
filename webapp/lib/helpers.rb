module AppHelpers

  def to_chartjs(es)

    fills  = [ "#FFF1AB", "#FFD2AB", "#FFE9AB", "#A2F2E9", "#F9A3C9", "#BD7DEC" ]
    stroke = [ "#7B59DC", "#5392D8", "#66F9AB", "#FF9D54", "#C1F09B", "#FFC5A5" ]

    data     = { 'labels' => [], 'datasets' => []}
    datasets = {}
    es['aggregations']['timestamps']['buckets'].each_with_index do |bucket, index|
      data['labels'] << bucket['key_as_string']
      bucket['test_cases']['buckets'].each do |sbucket|
        datasets[sbucket['key']] ||= []
        datasets[sbucket['key']][index] = sbucket['stats']['avg']
      end
    end
    i = 0
    datasets.each_pair do |label, values|
      values.map! { |value| value.to_i }
      colors = { :fill => fills[i%fills.size], :stroke => stroke[i%stroke.size] }
      data['datasets'] << build_dataset(label,values, colors)
      i=i+1
    end
    data["labels"].map! do |e| Date.parse(e).strftime end
    data
  end

  def build_dataset(label, values, colors)
    {
      :label =>  label,
      :fillColor => "rgba(220,220,220,0)",
      :strokeColor => colors[:stroke],
      :pointColor => colors[:stroke],
      :pointStrokeColor => colors[:stroke],
      :pointHighlightFill => "#fff",
      :pointHighlightStroke => colors[:stroke],
      :data => values
    }
  end

end

