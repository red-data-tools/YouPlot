module Uplot
  class Command
    def initialize(argv)
      @params = {}
      @ptype = nil
      parse_options(argv)
    end

    def parse_options(argv)
      parser = OptionParser.new
      parser.order!(argv)
      @ptype = argv.shift

      subparsers = Hash.new do |_h, k|
        warn "no such subcommand: #{k}"
        exit 1
      end

      subparsers['hist'] = OptionParser.new.tap do |sub|
        sub.on('--nbins VAL') { |v| @params[:nbins] = v.to_i }
        sub.on('-p') { |v| @params[:p] = v }
      end

      subparsers[@ptype].parse!(argv) unless argv.empty?
    end

    def run
      input_lines = readlines.map(&:chomp)
      case @ptype
      when 'hist', 'histogram'
        histogram(input_lines).render
      when 'line', 'lineplot'
        line(input_lines).render
      when 'lines'
        lines(input_lines).render
      end

      puts input_lines if @params[:p]
    end

    def histogram(input_lines)
      series = input_lines.map(&:to_f)
      UnicodePlot.histogram(series, nbins: @params[:nbins])
    end

    def line(input_lines)
      x = []
      y = []
      input_lines.each_with_index do |l, i|
        x[i], y[i] = l.split("\t")[0..1].map(&:to_f)
      end

      UnicodePlot.lineplot(x, y)
    end

    def lines(input_lines)
      n_cols = input_lines[0].split("\t").size
      cols = Array.new(n_cols){ [] }
      input_lines.each_with_index do |row, i|
        row.split("\t").each_with_index do |v, j|
          cols[j][i] = v.to_f
        end
      end
      require 'numo/narray'
      pp Numo::DFloat.cast(cols)
      plot = UnicodePlot.lineplot(cols[0], cols[1])
      2.upto(n_cols - 1) do |i|
        UnicodePlot.lineplot!(plot, cols[0], cols[i])
      end
      plot
    end
  end
end
