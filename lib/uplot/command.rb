module Uplot
  class Command
    def initialize(argv)
      @params = {}
      @ptype = nil
      parse_options(argv)
    end

    def parse_options(argv)
      parser = OptionParser.new.tap do |opt|
        opt.on('-p', '--print') { |v| @print = v }
        opt.on('--width VAL') { |v| @params[:width] = v.to_i }
        opt.on('--height VAL') { |v| @params[:height] = v.to_i }
      end
      parser.order!(argv)
      @ptype = argv.shift

      subparsers = Hash.new do |_h, k|
        warn "no such subcommand: #{k}"
        exit 1
      end

      subparsers['hist'] = OptionParser.new.tap do |sub|
        sub.on('--nbins VAL') { |v| @params[:nbins] = v.to_i }
      end
      subparsers['histogram'] = subparsers['hist']

      subparsers['line'] = OptionParser.new.tap do |sub|
      end
      subparsers['lineplot'] = subparsers['line']

      subparsers['lines'] = OptionParser.new.tap do |sub|
      end

      subparsers[@ptype].parse!(argv) unless argv.empty?
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
