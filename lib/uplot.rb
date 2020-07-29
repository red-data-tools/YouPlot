require 'uplot/version'
require 'unicode_plot'
require 'optparse'

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
      end

      puts input_lines if @params[:p]
    end

    def histogram(input_lines)
      series = input_lines.map(&:to_f)
      UnicodePlot.histogram(series, nbins: @params[:nbins])
    end
  end
end
