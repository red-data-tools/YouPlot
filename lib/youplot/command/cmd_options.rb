# frozen_string_literal: true

module YouPlot
  class Command
    CmdOptions = Struct.new(
      :delimiter,
      :transpose,
      :headers,
      :pass,
      :output,
      :fmt,
      :encoding,
      :color_names,
      :debug,
      keyword_init: true
    )
  end
end
