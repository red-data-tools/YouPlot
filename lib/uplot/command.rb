require 'optparse'
require_relative 'preprocessing'
require_relative 'command/params'
require_relative 'command/parser'

module Uplot
  Data = Struct.new(:headers, :series)

  class Command
    attr_accessor :params
    attr_reader :raw_inputs, :data, :fmt, :parser

    def initialize
      @params = Params.new

      @command    = nil
      @headers    = nil
      @delimiter  = "\t"
      @transpose  = false
      @output     = false
      @count      = false
      @fmt        = 'xyy'

      @raw_inputs = []
      @debug      = false

      @parser = Parser.new
    end


    def run
      parser.parse_options
      command = parser.command
      params = parser.params

      if command == :colors
        Plot.colors
        exit
      end

      # Sometimes the input file does not end with a newline code.
      while input = Kernel.gets(nil)
        input.freeze
        @raw_inputs << input
        @data = Preprocessing.input(input, @delimiter, @headers, @transpose)
        pp @data if @debug
        case command
        when :bar, :barplot
          Plot.barplot(data, params, @count)
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
        end.render($stderr)

        print input if @output
      end
    end
  end
end
