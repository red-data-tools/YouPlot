module Uplot
  class Command
    def initialize(argv)
      @params = {}
      @ptype = nil
      parse_options(argv)
    end

    def parse_options(argv)
      parser = OptionParser.new do |opt|
        add_common_opts(opt)
      end

      subparsers = Hash.new do |_h, k|
        warn "no such subcommand: #{k}"
        exit 1
      end

      subparsers['hist'] = OptionParser.new do |sub|
        sub.on('--nbins VAL', Numeric) { |v| @params[:nbins] = v }
        add_common_opts(sub)
      end
      subparsers['histogram'] = subparsers['hist']

      subparsers['line'] = OptionParser.new do |sub|
        add_common_opts(sub)
      end
      subparsers['lineplot'] = subparsers['line']

      subparsers['lines'] = OptionParser.new do |sub|
        add_common_opts(sub)
      end

      parser.banner = <<~MSG
        Usage:\tuplot <command> [options]
        Command:\t#{subparsers.keys.join(' ')}
      MSG
      parser.order!(argv)
      @ptype = argv.shift
      subparsers[@ptype].parse!(argv) unless argv.empty?
    end

    def add_common_opts(opt)
      opt.on('-o', '--output', TrueClass) { |v| @print = v }
      opt.on('-t', '--title VAL', String) { |v| @params[:title] = v }
      opt.on('-w', '--width VAL', Numeric) { |v| @params[:width] = v }
      opt.on('-h', '--height VAL', Numeric) { |v| @params[:height] = v }
      opt.on('-b', '--border VAL', Numeric) { |v| @params[:border] = v }
      opt.on('-m', '--margin VAL', Numeric) { |v| @params[:margin] = v }
      opt.on('-p', '--padding VAL', Numeric) { |v| @params[:padding] = v }
      opt.on('-l', '--labels', TrueClass) { |v| @params[:labels] = v }
    end

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
