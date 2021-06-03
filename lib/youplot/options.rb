# frozen_string_literal: true

module YouPlot
  # Command line options that are not Plot parameters
  Options = Struct.new(
    :delimiter,
    :transpose,
    :headers,
    :pass,
    :output,
    :fmt,
    :progressive,
    :encoding,
    :reverse,      # count
    :color_names,  # color
    :debug
  )
end
