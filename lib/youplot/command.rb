# frozen_string_literal: true

require_relative 'preprocessing'
require_relative 'command/parser'

# FIXME
require_relative 'backends/unicode_plot_backend'

module YouPlot
  Data = Struct.new(:headers, :series)

  class Command
    attr_accessor :params
    attr_reader :data, :fmt, :parser

    def initialize
      @params  = Params.new
      @parser  = Parser.new
      @backend = YouPlot::Backends::UnicodePlotBackend
    end

    def run
      parser.parse_options
      command   = parser.command
      params    = parser.params
      delimiter = parser.delimiter
      transpose = parser.transpose
      headers   = parser.headers
      pass      = parser.pass
      output    = parser.output
      fmt       = parser.fmt
      @debug    = parser.debug

      if command == :colors
        @backend.colors(parser.color_names)
        exit
      end

      # Sometimes the input file does not end with a newline code.
      while (input = Kernel.gets(nil))
        input.freeze
        @data = Preprocessing.input(input, delimiter, headers, transpose)
        pp @data if @debug
        plot = case command
               when :bar, :barplot
                 @backend.barplot(data, params)
               when :count, :c
                 @backend.barplot(data, params, count: true)
               when :hist, :histogram
                 @backend.histogram(data, params)
               when :line, :lineplot
                 @backend.line(data, params)
               when :lines, :lineplots
                 @backend.lines(data, params, fmt)
               when :scatter, :s
                 @backend.scatter(data, params, fmt)
               when :density, :d
                 @backend.density(data, params, fmt)
               when :box, :boxplot
                 @backend.boxplot(data, params)
               else
                 raise "unrecognized plot_type: #{command}"
               end

        if output.is_a?(IO)
          plot.render(output)
        else
          File.open(output, 'w') do |f|
            plot.render(f)
          end
        end

        if pass.is_a?(IO)
          print input
        elsif pass
          File.open(pass, 'w') do |f|
            f.print(input)
          end
        end
      end
    end
  end
end
