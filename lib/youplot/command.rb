# frozen_string_literal: true

require_relative 'dsv_reader'
require_relative 'command/parser'

# FIXME
require_relative 'backends/unicode_plot_backend'

module YouPlot
  Data = Struct.new(:headers, :series)

  class Command
    attr_accessor :command, :params, :options
    attr_reader :data, :parser

    def initialize(argv = ARGV)
      @argv    = argv
      @parser  = Parser.new
      @command = nil
      @params  = nil
      @options = nil
      @backend = YouPlot::Backends::UnicodePlotBackend
    end

    def run
      parser.parse_options(@argv)
      @command ||= parser.command
      @options ||= parser.options
      @params  ||= parser.params

      if command == :colors
        @backend.colors(parser.color_names)
        exit
      end

      # Sometimes the input file does not end with a newline code.
      while (input = Kernel.gets(nil))

        # Pass the input to subsequent pipelines
        case @options[:pass]
        when IO
          @options[:pass].print(input)
        else
          if @options[:pass]
            File.open(@options[:pass], 'w') do |f|
              f.print(input)
            end
          end
        end

        @data = if @options[:encoding]
                  input2 = input.dup.force_encoding(@options[:encoding]).encode('utf-8')
                  DSVReader.input(input2, @options[:delimiter], @options[:headers], @options[:transpose])
                else
                  DSVReader.input(input, @options[:delimiter], @options[:headers], @options[:transpose])
                end

        pp @data if @options[:debug]

        plot = case command
               when :bar, :barplot
                 @backend.barplot(data, params, @options[:fmt])
               when :count, :c
                 @backend.barplot(data, params, count: true)
               when :hist, :histogram
                 @backend.histogram(data, params)
               when :line, :lineplot
                 @backend.line(data, params, @options[:fmt])
               when :lines, :lineplots
                 @backend.lines(data, params, @options[:fmt])
               when :scatter, :s
                 @backend.scatter(data, params, @options[:fmt])
               when :density, :d
                 @backend.density(data, params, @options[:fmt])
               when :box, :boxplot
                 @backend.boxplot(data, params)
               else
                 raise "unrecognized plot_type: #{command}"
               end

        case @options[:output]
        when IO
          plot.render(@options[:output])
        else
          File.open(@options[:output], 'w') do |f|
            plot.render(f)
          end
        end

      end
    end
  end
end
