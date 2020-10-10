# frozen_string_literal: true

require_relative 'preprocessing'
require_relative 'command/parser'

module Uplot
  Data = Struct.new(:headers, :series)

  class Command
    attr_accessor :params
    attr_reader :raw_inputs, :data, :fmt, :parser

    def initialize
      @params = Params.new

      @raw_inputs = []

      @parser = Parser.new
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
      @debug     = parser.debug

      if command == :colors
        Plot.colors
        exit
      end

      # Sometimes the input file does not end with a newline code.
      while (input = Kernel.gets(nil))
        input.freeze
        @raw_inputs << input
        @data = Preprocessing.input(input, delimiter, headers, transpose)
        pp @data if @debug
        plot = case command
               when :bar, :barplot
                 Plot.barplot(data, params)
               when :count, :c
                 Plot.barplot(data, params, count = true)
               when :hist, :histogram
                 Plot.histogram(data, params)
               when :line, :lineplot
                 Plot.line(data, params)
               when :lines, :lineplots
                 Plot.lines(data, params, fmt)
               when :scatter, :s
                 Plot.scatter(data, params, fmt)
               when :density, :d
                 Plot.density(data, params, fmt)
               when :box, :boxplot
                 Plot.boxplot(data, params)
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
