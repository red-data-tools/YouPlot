require 'optparse'
require 'csv'
require 'unicode_plot'

module Uplot
  Data = Struct.new(:headers, :series)

  module Preprocess
    module_function

    def input(input, delimiter, headers, transpose)
      arr = read_csv(input, delimiter)
      headers = get_headers(arr, headers, transpose)
      series = get_series(arr, headers, transpose)
      Data.new(headers, series)
    end

    def read_csv(input, delimiter)
      CSV.parse(input, col_sep: delimiter)
         .delete_if do |i|
           i == [] or i.all? nil
         end
    end

    # Transpose different sized ruby arrays
    # https://stackoverflow.com/q/26016632
    def transpose2(arr)
      Array.new(arr.map(&:length).max) { |i| arr.map { |e| e[i] } }
    end

    def get_headers(arr, headers, transpose)
      if headers
        if transpose
          arr.map(&:first)
        else
          arr[0]
        end
      end
    end

    def get_series(arr, headers, transpose)
      if transpose
        if headers
          arr.map { |row| row[1..-1] }
        else
          arr
        end
      else
        if headers
          transpose2(arr[1..-1])
        else
          transpose2(arr)
        end
      end
    end

    def count(arr)
      # tally was added in Ruby 2.7
      if Enumerable.method_defined? :tally
        arr.tally
      else
        # https://github.com/marcandre/backports
        arr.each_with_object(Hash.new(0)) { |item, res| res[item] += 1 }
           .tap { |h| h.default = nil }
      end
        .sort { |a, b| a[1] <=> b[1] }
        .reverse
        .transpose
    end
  end

  class Command
    Params = Struct.new(
      # Sort me!
      :title,
      :width,
      :height,
      :border,
      :margin,
      :padding,
      :color,
      :xlabel,
      :ylabel,
      :labels,
      :symbol,
      :xscale,
      :nbins,
      :closed,
      :canvas,
      :xlim,
      :ylim,
      :grid,
      :name
    ) do
      def to_hc
        to_h.compact
      end
    end

    attr_accessor :params, :plot_type
    attr_reader :raw_inputs

    def initialize(argv)
      @params = Params.new

      @plot_type = nil
      @headers   = nil
      @delimiter = "\t"
      @transpose = false
      @output    = false
      @count     = false
      @fmt       = 'xyy'

      @raw_inputs = []
      @debug      = false

      parse_options(argv)
    end

    def create_parser
      OptionParser.new do |opt|
        opt.program_name = 'uplot'
        opt.version = Uplot::VERSION
        opt.on('-o', '--output', TrueClass) do |v|
          @output = v
        end
           .on('-d', '--delimiter VAL', String) do |v|
          @delimiter = v
        end
           .on('-H', '--headers', TrueClass) do |v|
          @headers = v
        end
           .on('-T', '--transpose', TrueClass) do |v|
          @transpose = v
        end
           .on('-t', '--title VAL', String) do |v|
          params.title = v
        end
           .on('-w', '--width VAL', Numeric) do |v|
          params.width = v
        end
           .on('-h', '--height VAL', Numeric) do |v|
          params.height = v
        end
           .on('-b', '--border VAL', Numeric) do |v|
          params.border = v
        end
           .on('-m', '--margin VAL', Numeric) do |v|
          params.margin = v
        end
           .on('-p', '--padding VAL', Numeric) do |v|
          params.padding = v
        end
           .on('-c', '--color VAL', String) do |v|
          params.color = v.to_sym
        end
           .on('-x', '--xlabel VAL', String) do |v|
          params.xlabel = v
        end
           .on('-y', '--ylabel VAL', String) do |v|
          params.ylabel = v
        end
           .on('-l', '--labels', TrueClass) do |v|
          params.labels = v
        end
           .on('--fmt VAL', String) do |v|
          @fmt = v
        end
           .on('--debug', TrueClass) do |v|
          @debug = v
        end
      end
    end

    def parse_options(argv)
      main_parser = create_parser
      parsers = Hash.new { |h, k| h[k] = create_parser }

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

      # Preventing the generation of new sub-commands
      parsers.default = nil

      # Usage and help messages
      main_parser.banner = \
        <<~MSG
          Program: uplot (Tools for plotting on the terminal)
          Version: #{Uplot::VERSION} (using unicode_plot #{UnicodePlot::VERSION})

          Usage:   uplot <command> [options]

          Command: #{parsers.keys.join(' ')}

          Options:
        MSG

      begin
        main_parser.order!(argv)
      rescue OptionParser::ParseError => e
        warn "uplot: #{e.message}"
        exit 1
      end

      @plot_type = argv.shift&.to_sym

      unless parsers.has_key?(plot_type)
        if plot_type.nil?
          warn main_parser.help
        else
          warn "uplot: unrecognized command '#{plot_type}'"
        end
        exit 1
      end
      parser = parsers[plot_type]

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
      # Sometimes the input file does not end with a newline code.
      while input = Kernel.gets(nil)
        input.freeze
        @raw_inputs << input
        @data = Preprocess.input(input, @delimiter, @headers, @transpose)
        case plot_type
        when :bar, :barplot
          barplot(@data)
        when :count, :c
          @count = true
          barplot(@data)
        when :hist, :histogram
          histogram(@data)
        when :line, :lineplot
          line(@data)
        when :lines, :lineplots
          lines(@data)
        when :scatter, :scatterplot
          scatter(@data)
        when :density
          density(@data)
        when :box, :boxplot
          boxplot(@data)
        else
          raise "unrecognized plot_type: #{plot_type}"
        end.render($stderr)

        print input if @output
      end
    end

    def barplot(data)
      headers = data.headers
      series = data.series
      if @count
        series = Preprocess.count(series[0])
        params.title = headers[0] if headers
      end
      params.title ||= headers[1] if headers
      labels = series[0]
      values = series[1].map(&:to_f)
      UnicodePlot.barplot(labels, values, **params.to_hc)
    end

    def histogram(data)
      headers = data.headers
      series = data.series
      params.title ||= data.headers[0] if headers
      values = series[0].map(&:to_f)
      UnicodePlot.histogram(values, **params.to_hc)
    end

    def line(data)
      headers = data.headers
      series = data.series
      if series.size == 1
        # If there is only one series, it is assumed to be sequential data.
        params.ylabel ||= headers[0] if headers
        y = series[0].map(&:to_f)
        UnicodePlot.lineplot(y, **params.to_hc)
      else
        # If there are 2 or more series,
        # assume that the first 2 series are the x and y series respectively.
        if headers
          params.xlabel ||= headers[0]
          params.ylabel ||= headers[1]
        end
        x = series[0].map(&:to_f)
        y = series[1].map(&:to_f)
        UnicodePlot.lineplot(x, y, **params.to_hc)
      end
    end

    def get_method2(method1)
      (method1.to_s + '!').to_sym
    end

    def xyy_plot(data, method1)
      headers = data.headers
      series = data.series
      method2 = get_method2(method1)
      series.map! { |s| s.map(&:to_f) }
      if headers
        params.name   ||= headers[1]
        params.xlabel ||= headers[0]
      end
      params.ylim ||= series[1..-1].flatten.minmax # why need?
      plot = UnicodePlot.public_send(method1, series[0], series[1], **params.to_hc)
      2.upto(series.size - 1) do |i|
        UnicodePlot.public_send(method2, plot, series[0], series[i], name: headers&.[](i))
      end
      plot
    end

    def xyxy_plot(data, method1)
      headers = data.headers
      series = data.series
      method2 = get_method2(method1)
      series.map! { |s| s.map(&:to_f) }
      series = series.each_slice(2).to_a
      params.name ||= headers[0] if headers
      params.xlim = series.map(&:first).flatten.minmax # why need?
      params.ylim = series.map(&:last).flatten.minmax  # why need?
      x1, y1 = series.shift
      plot = UnicodePlot.public_send(method1, x1, y1, **params.to_hc)
      series.each_with_index do |(xi, yi), i|
        UnicodePlot.public_send(method2, plot, xi, yi, name: headers&.[]((i + 1) * 2))
      end
      plot
    end

    def lines(data)
      case @fmt
      when 'xyy'
        xyy_plot(data, :lineplot)
      when 'xyxy'
        xyxy_plot(data, :lineplot)
      end
    end

    def scatter(data)
      case @fmt
      when 'xyy'
        xyy_plot(data, :scatterplot)
      when 'xyxy'
        xyxy_plot(data, :scatterplot)
      end
    end

    def density(data)
      case @fmt
      when 'xyy'
        xyy_plot(data, :densityplot)
      when 'xyxy'
        xyxy_plot(data, :densityplot)
      end
    end

    def boxplot(data)
      headers = data.headers
      series = data.series
      headers ||= (1..series.size).map(&:to_s)
      series.map! { |s| s.map(&:to_f) }
      UnicodePlot.boxplot(headers, series, params.to_hc)
    end
  end
end
