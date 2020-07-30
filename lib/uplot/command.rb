module Uplot
  class Command
    def initialize(argv)
      @params = {}
      @ptype = nil
      parse_options(argv)
    end

    def opt_new
      OptionParser.new do |opt|
        opt.on('-o', '--output', TrueClass) { |v| @print = v }
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

    def set_common_opts(opt); end

    def run
      # Sometimes the input file does not end with a newline code.
      while input = Kernel.gets(nil)
        input_lines = input.split(/\R/)
        case @ptype
        when 'hist', 'histogram'
          histogram(input_lines)
        when 'line', 'lineplot'
          line(input_lines)
        when 'lines'
          lines(input_lines)
        end.render($stderr)

        print input if @print
      end
    end

    def histogram(input_lines)
      series = input_lines.map(&:to_f)
      UnicodePlot.histogram(series, **@params.compact)
    end

    def line(input_lines)
      x = []
      y = []
      input_lines.each_with_index do |l, i|
        x[i], y[i] = l.split("\t")[0..1].map(&:to_f)
      end
      UnicodePlot.lineplot(x, y, **@params.compact)
    end

    def lines(input_lines)
      n_cols = input_lines[0].split("\t").size
      cols = Array.new(n_cols) { [] }
      input_lines.each_with_index do |row, i|
        row.split("\t").each_with_index do |v, j|
          cols[j][i] = v.to_f
        end
      end
      plot = UnicodePlot.lineplot(cols[0], cols[1], **@params.compact)
      2.upto(n_cols - 1) do |i|
        UnicodePlot.lineplot!(plot, cols[0], cols[i])
      end
      plot
    end
  end
end
