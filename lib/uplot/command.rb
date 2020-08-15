require 'optparse'
require 'csv'
require 'unicode_plot'

module Uplot
  class Command
    Params = Struct.new(
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
      :grid
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

    def run
      # Sometimes the input file does not end with a newline code.
      while input = Kernel.gets(nil)
        input.freeze
        @raw_inputs << input
        data, headers = preprocess(input)
        pp input: input, data: data, headers: headers if @debug
        case plot_type
        when :bar, :barplot
          barplot(data, headers)
        when :count, :c
          @count = true
          barplot(data, headers)
        when :hist, :histogram
          histogram(data, headers)
        when :line, :lineplot
          line(data, headers)
        when :lines, :lineplots
          lines(data, headers)
        when :scatter, :scatterplot
          scatter(data, headers)
        when :density
          density(data, headers)
        when :box, :boxplot
          boxplot(data, headers)
        else
          raise "unrecognized plot_type: #{plot_type}"
        end.render($stderr)

        print input if @output
      end
    end

    # Transpose different sized ruby arrays
    # https://stackoverflow.com/q/26016632
    def transpose2(arr)
      Array.new(arr.map(&:length).max) { |i| arr.map { |e| e[i] } }
    end

    def preprocess(input)
      data = CSV.parse(input, col_sep: @delimiter)
      data.delete([]) # Remove blank lines.
      data.delete_if { |i| i.all? nil } # Room for improvement.
      p parsed_csv: data if @debug
      headers = get_headers(data)
      data = get_data(data)
      [data, headers]
    end

    def get_headers(data)
      if @headers
        if @transpose
          data.map(&:first)
        else
          data[0]
        end
      end
    end

    def get_data(data)
      if @transpose
        if @headers
          data.map { |row| row[1..-1] }
        else
          data
        end
      else
        if @headers
          transpose2(data[1..-1])
        else
          transpose2(data)
        end
      end
    end

    def preprocess_count(data)
      # tally was added in Ruby 2.7
      if Enumerable.method_defined? :tally
        data[0].tally
      else
        # https://github.com/marcandre/backports
        data[0].each_with_object(Hash.new(0)) { |item, res| res[item] += 1 }
               .tap { |h| h.default = nil }
      end
        .sort { |a, b| a[1] <=> b[1] }
        .reverse
        .transpose
    end

    def barplot(data, headers)
      data = preprocess_count(data) if @count
      params.title ||= headers[1] if headers
      UnicodePlot.barplot(data[0], data[1].map(&:to_f), **params.to_hc)
    end

    def histogram(data, headers)
      params.title ||= headers[0] if headers # labels?
      series = data[0].map(&:to_f)
      UnicodePlot.histogram(series, **params.to_hc)
    end

    def get_lim(str)
      str.split(/-|:|\.\./)[0..1].map(&:to_f)
    end

    def line(data, headers)
      if data.size == 1
        params.ylabel ||= headers[0] if headers
        y = data[0].map(&:to_f)
        UnicodePlot.lineplot(y, **params.to_hc)
      else
        params.xlabel ||= headers[0] if headers
        params.ylabel ||= headers[1] if headers
        x = data[0].map(&:to_f)
        y = data[1].map(&:to_f)
        UnicodePlot.lineplot(x, y, **params.to_hc)
      end
    end

    def get_method2(method1)
      (method1.to_s + '!').to_sym
    end

    def xyy_plot(data, headers, method1) # improve method name
      method2 = get_method2(method1)
      data.map! { |series| series.map(&:to_f) }
      params.name ||= headers[1] if headers
      params.xlabel ||= headers[0] if headers
      params.ylim ||= data[1..-1].flatten.minmax # need?
      plot = UnicodePlot.public_send(method1, data[0], data[1], **params.to_hc)
      2.upto(data.size - 1) do |i|
        UnicodePlot.public_send(method2, plot, data[0], data[i], name: headers[i])
      end
      plot
    end

    def xyxy_plot(data, headers, method1) # improve method name
      method2 = get_method2(method1)
      data.map! { |series| series.map(&:to_f) }
      data = data.each_slice(2).to_a
      params.name ||= headers[0] if headers
      params.xlim = data.map(&:first).flatten.minmax
      params.ylim = data.map(&:last).flatten.minmax
      x1, y1 = data.shift
      plot = UnicodePlot.public_send(method1, x1, y1, **params.to_hc)
      data.each_with_index do |(xi, yi), i|
        UnicodePlot.public_send(method2, plot, xi, yi, name: headers[(i + 1) * 2])
      end
      plot
    end

    def lines(data, headers)
      case @fmt
      when 'xyy'
        xyy_plot(data, headers, :lineplot)
      when 'xyxy'
        xyxy_plot(data, headers, :lineplot)
      end
    end

    def scatter(data, headers)
      case @fmt
      when 'xyy'
        xyy_plot(data, headers, :scatterplot)
      when 'xyxy'
        xyxy_plot(data, headers, :scatterplot)
      end
    end

    def density(data, headers)
      case @fmt
      when 'xyy'
        xyy_plot(data, headers, :densityplot)
      when 'xyxy'
        xyxy_plot(data, headers, :densityplot)
      end
    end

    def boxplot(data, headers)
      headers ||= (1..data.size).map(&:to_s)
      data.map! { |series| series.map(&:to_f) }
      UnicodePlot.boxplot(headers, data, params.to_hc)
    end
  end
end
