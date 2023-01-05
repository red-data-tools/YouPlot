# frozen_string_literal: true

require_relative 'dsv'
require_relative 'parser'

# FIXME
require_relative 'backends/unicode_plot'

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
      @backend = YouPlot::Backends::UnicodePlot
    end

    def run_as_executable
      YouPlot.run_as_executable = true
      run
    end

    def run
      parser.parse_options(@argv)
      @command ||= parser.command
      @options ||= parser.options
      @params  ||= parser.params

      # color command
      if %i[colors color colours colour].include? @command
        plot = create_plot
        output_plot(plot)
        return
      end

      # progressive mode
      if options[:progressive]
        stop = false
        Signal.trap(:INT) { stop = true }

        # make cursor invisible
        options[:output].print "\e[?25l"

        # mainloop
        while (input = Kernel.gets)
          n = main_progressive(input)
          break if stop

          options[:output].print "\e[#{n}F"
        end

        options[:output].print "\e[0J"
        # make cursor visible
        options[:output].print "\e[?25h"

      # normal mode
      else
        # Sometimes the input file does not end with a newline code.
        begin
          begin
            input = Kernel.gets(nil)
          rescue Errno::ENOENT => e
            warn e.message
            next
          end
          main(input)
        end until input
      end
    end

    private

    def main(input)
      # Outputs input data to a file or stdout.
      output_data(input)

      @data = parse_dsv(input)

      # Debug mode, show parsed results
      pp @data if options[:debug]

      # When run as a program instead of a library
      if YouPlot.run_as_executable?
        begin
          plot = create_plot
        rescue ArgumentError => e
          # Show only one line of error.
          warn e.backtrace[0]
          # Show error message in purple
          warn "\e[35m#{e}\e[0m"
          # Explicitly terminated with exit code: 1
          exit 1
        end

      # When running YouPlot as a library (e.g. for testing)
      else
        plot = create_plot
      end

      output_plot(plot)
    end

    def main_progressive(input)
      output_data(input)

      # FIXME
      # Worked around the problem of not being able to draw
      # plots when there is only one header line.
      if @raw_data.nil?
        @raw_data = String.new
        if options[:headers]
          @raw_data << input
          return
        end
      end
      @raw_data << input

      # FIXME
      @data = parse_dsv(@raw_data)

      plot = create_plot
      output_plot_progressive(plot)
    end

    def parse_dsv(input)
      # If encoding is specified, convert to UTF-8
      if options[:encoding]
        input.force_encoding(options[:encoding])
             .encode!('utf-8')
      end

      begin
        data = DSV.parse(input, options[:delimiter], options[:headers], options[:transpose])
      rescue CSV::MalformedCSVError => e
        warn 'Failed to parse the text. '
        warn 'Please try to set the correct character encoding with --encoding option.'
        warn e.backtrace.grep(/youplot/).first
        exit 1
      rescue ArgumentError => e
        warn 'Failed to parse the text. '
        warn e.backtrace.grep(/youplot/).first
        exit 1
      end

      data
    end

    def create_plot
      case command
      when :bar, :barplot
        @backend.barplot(data, params, options[:fmt])
      when :count, :c
        @backend.barplot(data, params, count: true, reverse: options[:reverse])
      when :hist, :histogram
        @backend.histogram(data, params)
      when :line, :lineplot, :l
        @backend.line(data, params, options[:fmt])
      when :lines, :lineplots, :ls
        @backend.lines(data, params, options[:fmt])
      when :scatter, :s
        @backend.scatter(data, params, options[:fmt])
      when :density, :d
        @backend.density(data, params, options[:fmt])
      when :box, :boxplot
        @backend.boxplot(data, params)
      when :colors, :color, :colours, :colour
        @backend.colors(options[:color_names])
      else
        raise "unrecognized plot_type: #{command}"
      end
    end

    def output_data(input)
      # Pass the input to subsequent pipelines
      case options[:pass]
      when IO, StringIO
        options[:pass].print(input)
      else
        if options[:pass]
          File.open(options[:pass], 'w') do |f|
            f.print(input)
          end
        end
      end
    end

    def output_plot(plot)
      case options[:output]
      when IO, StringIO
        plot.render(options[:output])
      when String, Tempfile
        File.open(options[:output], 'w') do |f|
          plot.render(f)
        end
      end
    end

    def output_plot_progressive(plot)
      case options[:output]
      when IO, StringIO
        # RefactorMe
        out = StringIO.new(String.new)
        def out.tty?
          true
        end
        plot.render(out)
        lines = out.string.lines
        lines.each do |line|
          options[:output].print line.chomp
          options[:output].print "\e[0K"
          options[:output].puts
        end
        options[:output].print "\e[0J"
        options[:output].flush
        out.string.lines.size
      else
        raise 'In progressive mode, output to a file is not possible.'
      end
    end
  end
end
