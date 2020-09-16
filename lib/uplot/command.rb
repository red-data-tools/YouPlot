require 'optparse'
require_relative 'preprocessing'
require_relative 'command/params'

module Uplot
  Data = Struct.new(:headers, :series)

  class Command
    attr_accessor :params, :command
    attr_reader :main_parser, :sub_parsers, :raw_inputs, :data, :fmt

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
    end

    def create_default_parser
      OptionParser.new do |opt|
        opt.program_name = 'uplot'
        opt.version = Uplot::VERSION
        opt.on('-O', '--output', TrueClass) do |v|
          @output = v
        end
           .on('-d', '--delimiter VAL', 'Use DELIM instead of TAB for field delimiter.', String) do |v|
          @delimiter = v
        end
           .on('-H', '--headers', 'Specify that the input has header row.', TrueClass) do |v|
          @headers = v
        end
           .on('-T', '--transpose', TrueClass) do |v|
          @transpose = v
        end
           .on('-t', '--title VAL', 'Title for the plot', String) do |v|
          params.title = v
        end
           .on('-x', '--xlabel VAL', 'The string to display on the bottom of the plot', String) do |v|
          params.xlabel = v
        end
           .on('-y', '--ylabel VAL', 'The string to display on the far left of the plot.', String) do |v|
          params.ylabel = v
        end
           .on('-w', '--width VAL', 'Number of characters per row.', Integer) do |v|
          params.width = v
        end
           .on('-h', '--height VAL', 'Number of rows.', Numeric) do |v|
          params.height = v
        end
           .on('-b', '--border VAL', 'The style of the bounding box of the plot.', String) do |v|
          params.border = v.to_sym
        end
           .on('-m', '--margin VAL', 'Number of empty characters to the left of the plot.', Numeric) do |v|
          params.margin = v
        end
           .on('-p', '--padding VAL', 'Space of the left and right of the plot.', Numeric) do |v|
          params.padding = v
        end
           .on('-c', '--color VAL', 'Color of the drawing.', String) do |v|
          params.color = v =~ /\A[0-9]+\z/ ? v.to_i : v.to_sym
        end
           .on('--[no-]labels', 'Hide the labels', TrueClass) do |v|
          params.labels = v
        end
           .on('--fmt VAL', 'xyy, xyxy', String) do |v|
          @fmt = v
        end
           .on('--debug', TrueClass) do |v|
          @debug = v
        end
        yield opt if block_given?
      end
    end

    def create_sub_parsers
      parsers = Hash.new do |h, k|
        h[k] = create_default_parser do |parser|
          parser.banner = <<~MSG
            Usage: uplot #{k} [options]

            Options:
          MSG
        end
      end

      parsers[:barplot] = \
        parsers[:bar]
        .on('--symbol VAL', String) do |v|
          params.symbol = v
        end
        .on('--xscale VAL', String) do |v|
          params.xscale = v
        end
        .on('--count', TrueClass) do |v|
          @count = v
        end

      parsers[:count] = \
        parsers[:c] # barplot -c
        .on('--symbol VAL', String) do |v|
          params.symbol = v
        end

      parsers[:histogram] = \
        parsers[:hist]
        .on('-n', '--nbins VAL', Numeric) do |v|
          params.nbins = v
        end
        .on('--closed VAL', String) do |v|
          params.closed = v
        end
        .on('--symbol VAL', String) do |v|
          params.symbol = v
        end

      parsers[:lineplot] = \
        parsers[:line]
        .on('--canvas VAL', String) do |v|
          params.canvas = v
        end
        .on('--xlim VAL', String) do |v|
          params.xlim = get_lim(v)
        end
        .on('--ylim VAL', String) do |v|
          params.ylim = get_lim(v)
        end

      parsers[:lineplots] = \
        parsers[:lines]
        .on('--canvas VAL', String) do |v|
          params.canvas = v
        end
        .on('--xlim VAL', String) do |v|
          params.xlim = get_lim(v)
        end
        .on('--ylim VAL', String) do |v|
          params.ylim = get_lim(v)
        end

      parsers[:scatter] = \
        parsers[:s]
        .on('--canvas VAL', String) do |v|
          params.canvas = v
        end
        .on('--xlim VAL', String) do |v|
          params.xlim = get_lim(v)
        end
        .on('--ylim VAL', String) do |v|
          params.ylim = get_lim(v)
        end

      parsers[:density] = \
        parsers[:d]
        .on('--grid', TrueClass) do |v|
          params.grid = v
        end
        .on('--xlim VAL', String) do |v|
          params.xlim = get_lim(v)
        end
        .on('--ylim VAL', String) do |v|
          params.ylim = get_lim(v)
        end

      parsers[:boxplot] = \
        parsers[:box]
        .on('--xlim VAL', String) do |v|
          params.xlim = get_lim(v)
        end

      parsers[:colors]
        .on('-n', '--names', TrueClass) do |v|
          @color_names = v
        end

      # Preventing the generation of new sub-commands
      parsers.default = nil
      parsers
    end

    def create_main_parser
      create_default_parser do |main_parser|
        # Usage and help messages
        main_parser.banner = \
          <<~MSG
            Program: uplot (Tools for plotting on the terminal)
            Version: #{Uplot::VERSION} (using unicode_plot #{UnicodePlot::VERSION})

            Usage:   uplot <command> [options]

            Command:
                #{sub_parsers.keys.join("\n    ")}

            Options:
          MSG
      end
    end

    def parse_options(argv = ARGV)
      @sub_parsers = create_sub_parsers
      @main_parser = create_main_parser

      begin
        main_parser.order!(argv)
      rescue OptionParser::ParseError => e
        warn "uplot: #{e.message}"
        exit 1
      end

      @command = argv.shift&.to_sym

      unless sub_parsers.has_key?(command)
        if command.nil?
          warn main_parser.help
        else
          warn "uplot: unrecognized command '#{command}'"
        end
        exit 1
      end
      parser = sub_parsers[command]

      begin
        parser.parse!(argv) unless argv.empty?
      rescue OptionParser::ParseError => e
        warn "uplot: #{e.message}"
        exit 1
      end
    end

    def get_lim(str)
      str.split(/-|:|\.\./)[0..1].map(&:to_f)
    end

    def run
      parse_options

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
