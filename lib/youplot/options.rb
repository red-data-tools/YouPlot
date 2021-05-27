# frozen_string_literal: true

module YouPlot
  Options = Struct.new(
    :delimiter,
    :transpose,
    :headers,
    :pass,
    :output,
    :fmt,
    :progressive,
    :encoding,
    :color_names,
    :debug,
    keyword_init: true
  )
end
