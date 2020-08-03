require 'optparse'
require 'csv'

module Uplot
  class Command
    def initialize(argv)
      @params = {}
      @ptype = nil
      @headers = nil
      @delimiter = "\t"
      @transpose = false
      @output = false
      @count = false
      @fmt = 'xyy'
      @debug = false
      parse_options(argv)
    end

    def create_parser
      OptionParser.new do |opt|
        opt.on('-o', '--output', TrueClass)     { |v| @output = v }
        opt.on('-d', '--delimiter VAL', String) { |v| @delimiter = v }
        opt.on('-H', '--headers', TrueClass)    { |v| @headers = v }
        opt.on('-T', '--transpose', TrueClass)  { |v| @transpose = v }
        opt.on('-t', '--title VAL', String)     { |v| @params[:title] = v }
        opt.on('-w', '--width VAL', Numeric)    { |v| @params[:width] = v }
        opt.on('-h', '--height VAL', Numeric)   { |v| @params[:height] = v }
        opt.on('-b', '--border VAL', Numeric)   { |v| @params[:border] = v }
        opt.on('-m', '--margin VAL', Numeric)   { |v| @params[:margin] = v }
        opt.on('-p', '--padding VAL', Numeric)  { |v| @params[:padding] = v }
        opt.on('-c', '--color VAL', String)     { |v| @params[:color] = v.to_sym }
        opt.on('-l', '--labels', TrueClass)     { |v| @params[:labels] = v }
        opt.on('--fmt VAL', String) { |v| @fmt = v }
        opt.on('--debug', TrueClass) { |v| @debug = v }
      end
    end

    def parse_options(argv)
      main_parser            = create_parser
      parsers                = Hash.new { |h, k| h[k] = create_parser }
      parsers['bar']         .on('--count', TrueClass) { |v| @count = v }
      parsers['barplot']     = parsers['bar']
      parsers['count']       = parsers['c'] # barplot -c
      parsers['hist']        .on('--nbins VAL', Numeric) { |v| @params[:nbins] = v }
      parsers['histogram'] = parsers['hist']
      parsers['line']        .on('-x', '--xlim VAL', String) { |v| @params[:xlim] = get_lim(v) }
      parsers['lineplot']    = parsers['line']
      parsers['lineplots']   = parsers['lines']
      parsers['scatterplot'] = parsers['scatter']
      parsers['densityplot'] = parsers['density']
      parsers['boxplot']     = parsers['box']
      parsers.default        = nil

      main_parser.banner = <<~MSG
        Program: Uplot (Tools for plotting on the terminal)
        Version: #{Uplot::VERSION} (using unicode_plot #{UnicodePlot::VERSION})

        Usage:   uplot <command> [options]

        Command: #{parsers.keys.join(' ')}

      MSG
      main_parser.order!(argv)
      @ptype = argv.shift

      unless parsers.has_key?(@ptype)
        puts main_parser.help
        warn "unrecognized command '#{@ptype}'"
        exit 1
      end
      parser = parsers[@ptype]
      parser.parse!(argv) unless argv.empty?
    end

    def run
      # Sometimes the input file does not end with a newline code.
      while input = Kernel.gets(nil)
        input.freeze
        data, headers = preprocess(input)
        pp input: input, data: data, headers: headers if @debug
        case @ptype
        when 'bar', 'barplot'
          barplot(data, headers)
        when 'count', 'c'
          @count = true
          barplot(data, headers)
        when 'hist', 'histogram'
          histogram(data, headers)
        when 'line', 'lineplot'
          line(data, headers)
        when 'lines', 'lineplots'
          lines(data, headers)
        when 'scatter', 'scatterplot'
          scatter(data, headers)
        when 'density'
          density(data, headers)
        when 'box', 'boxplot'
          boxplot(data, headers)
        end.render($stderr)

        print input if @output
      end
    end

    # Note: How can I transpose different sized ruby arrays?
    # https://stackoverflow.com/questions/26016632/how-can-i-transpose-different-sized-ruby-arrays
    def transpose2(arr) # Should be renamed
      Array.new(arr.map(&:length).max) { |i| arr.map { |e| e[i] } }
    end

    def preprocess(input)
      data = CSV.parse(input, col_sep: @delimiter)
      data.delete([]) # Remove blank lines.
      data.delete_if { |i| i.all? nil } # Room for improvement.
      p parsed_csv: data if @debug
      headers = nil
      if @transpose
        if @headers
          headers = []
          data.each { |series| headers << series.shift } # each but destructive like map
        end
      else
        headers = data.shift if @headers
        data = transpose2(data)
      end
      [data, headers]
    end

    def preprocess_count(data)
      data[0].tally.sort { |a, b| a[1] <=> b[1] }.reverse.transpose
    end

    def barplot(data, headers)
      data = preprocess_count(data) if @count
      @params[:title] ||= headers[1] if headers
      UnicodePlot.barplot(data[0], data[1].map(&:to_f), **@params)
    end

    def histogram(data, headers)
      @params[:title] ||= headers[0] if headers # labels?
      series = data[0].map(&:to_f)
      UnicodePlot.histogram(series, **@params.compact)
    end

    def get_lim(str)
      str.split(/-|:|\.\./)[0..1].map(&:to_f)
    end

    def line(data, headers)
      if data.size == 1
        @params[:ylabel] ||= headers[0] if headers
        y = data[0]
        x = (1..y.size).to_a
      else
        @params[:xlabel] ||= headers[0] if headers
        @params[:ylabel] ||= headers[1] if headers
        x = data[0]
        y = data[1]
      end
      x = x.map(&:to_f)
      y = y.map(&:to_f)
      UnicodePlot.lineplot(x, y, **@params.compact)
    end

    def xyy_plot(data, headers, call1, call2) # improve method name
      data.map! { |series| series.map(&:to_f) }
      @params[:name] ||= headers[1] if headers
      @params[:xlabel] ||= headers[0] if headers
      @params[:ylim] ||= data[1..-1].flatten.minmax # need?
      plot = UnicodePlot.public_send(call1, data[0], data[1], **@params.compact)
      2.upto(data.size - 1) do |i|
        UnicodePlot.public_send(call2, plot, data[0], data[i], name: headers[i])
      end
      plot
    end

    def xyxy_plot(data, headers, call1, call2) # improve method name
      data.map! { |series| series.map(&:to_f) }
      data = data.each_slice(2).to_a
      @params[:name] ||= headers[0] if headers
      @params[:xlim] = data.map(&:first).flatten.minmax
      @params[:ylim] = data.map(&:last).flatten.minmax
      x1, y1 = data.shift
      plot = UnicodePlot.public_send(call1, x1, y1, **@params.compact)
      data.each_with_index do |(xi, yi), i|
        UnicodePlot.public_send(call2, plot, xi, yi, name: headers[i * 2])
      end
      plot
    end

    def lines(data, headers)
      case @fmt
      when 'xyy'
        xyy_plot(data, headers, :lineplot, :lineplot!)
      when 'xyxy'
        xyxy_plot(data, headers, :lineplot, :lineplot!)
      end
    end

    def scatter(data, headers)
      case @fmt
      when 'xyy'
        xyy_plot(data, headers, :scatterplot, :scatterplot!)
      when 'xyxy'
        xyxy_plot(data, headers, :scatterplot, :scatterplot!)
      end
    end

    def density(data, headers)
      case @fmt
      when 'xyy'
        xyy_plot(data, headers, :densityplot, :densityplot!)
      when 'xyxy'
        xyxy_plot(data, headers, :densityplot, :densityplot!)
      end
    end

    def boxplot(data, headers)
      headers ||= (1..data.size).to_a
      data.map! { |series| series.map(&:to_f) }
      plot = UnicodePlot.boxplot(headers[0], data[0], **@params.compact)
      1.upto(data.size - 1) do |i|
        UnicodePlot.boxplot!(plot, headers[i], data[i])
      end
      plot
    end
  end
end

# backports
# https://github.com/marcandre/backports/blob/master/lib/backports/2.7.0/enumerable/tally.rb
unless Enumerable.method_defined? :tally
  module Enumerable
    def tally
      # NB: By spec, tally should return default-less hash
      each_with_object(Hash.new(0)) { |item, res| res[item] += 1 }.tap { |h| h.default = nil }
    end
  end
end
