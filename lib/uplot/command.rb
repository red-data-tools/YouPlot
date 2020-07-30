require 'optparse'
require 'csv'

module Uplot
  class Command
    def initialize(argv)
      @params = {}
      @ptype = nil
      parse_options(argv)
    end

    def opt_new
      OptionParser.new do |opt|
        opt.on('-o', '--output', TrueClass) { |v| @output = v }
        opt.on('-d', '--delimiter', String) { |v| @delimiter = v }
        opt.on('-t', '--title VAL', String) { |v| @params[:title] = v }
        opt.on('-w', '--width VAL', Numeric) { |v| @params[:width] = v }
        opt.on('-h', '--height VAL', Numeric) { |v| @params[:height] = v }
        opt.on('-b', '--border VAL', Numeric) { |v| @params[:border] = v }
        opt.on('-m', '--margin VAL', Numeric) { |v| @params[:margin] = v }
        opt.on('-p', '--padding VAL', Numeric) { |v| @params[:padding] = v }
        opt.on('-l', '--labels', TrueClass) { |v| @params[:labels] = v }
      end
    end

    def parse_options(argv)
      main_parser          = opt_new
      parsers              = {}
      parsers['hist']      = opt_new.on('--nbins VAL', Numeric) { |v| @params[:nbins] = v }
      parsers['histogram'] = parsers['hist']
      parsers['line']      = opt_new
      parsers['lineplot']  = parsers['line']
      parsers['lines']     = opt_new

      main_parser.banner = <<~MSG
        Usage:\tuplot <command> [options]
        Command:\t#{parsers.keys.join(' ')}
      MSG
      main_parser.order!(argv)
      @ptype = argv.shift

      unless parsers.has_key?(@ptype)
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
        @delimiter ||= "\t"
        @headers   ||= false
        data = CSV.parse(input, headers: @headers, col_sep: @delimiter)
        case @ptype
        when 'hist', 'histogram'
          histogram(data)
        when 'line', 'lineplot'
          line(data)
        when 'lines'
          lines(data)
        end.render($stderr)

        print input if @output
      end
    end

    def histogram(data)
      series = data.map { |r| r[0].to_f }
      UnicodePlot.histogram(series, **@params.compact)
    end

    def line(data)
      data = data.transpose
      if data.size == 1
        y = data[0]
        x = (1..y.size).to_a
      else
        x = data[0]
        y = data[1]
      end
      x = x.map(&:to_f)
      y = y.map(&:to_f)
      UnicodePlot.lineplot(x, y, **@params.compact)
    end

    def lines(_input_lines)
      data = data.transpose
      data.map { |series| series.map(&:to_f) }
      plot = UnicodePlot.lineplot(data[0], data[1], **@params.compact)
      2.upto(data.size - 1) do |i|
        UnicodePlot.lineplot!(plot, data[0], data[i])
      end
      plot
    end
  end
end
