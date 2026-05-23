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

  # Default values for options.
  # These are applied in Parser#resolve_options.
  # Based on the following priority:
  # 1. CLI options (highest priority)
  # 2. Config file options
  # 3. Default values (lowest priority) specified here.
  Options::DEFAULTS = {
    delimiter: "\t",
    transpose: false,
    headers: nil,
    pass: false,
    output: nil, # resolved to $stderr at parse time (late binding)
    fmt: 'xyy',
    progressive: false,
    encoding: nil,
    reverse: false,
    color_names: false,
    debug: false
  }.freeze
end
