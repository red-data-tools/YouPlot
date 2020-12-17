# frozen_string_literal: true

require 'optparse'
require_relative 'cmd_options'
require_relative 'plot_params'

module YouPlot
  class Command
    class Parser
      attr_reader :command, :options, :params

      def initialize
        @command = nil

        @options = CmdOptions.new(
          delimiter: "\t",
          transpose: false,
          headers: nil,
          pass: false,
          output: $stderr,
          fmt: 'xyy',
          encoding: nil,
          color_names: false,
          debug: false
        )

        @params = PlotParams.new
      end

      def create_default_parser
        OptionParser.new do |opt|
          opt.program_name  = 'YouPlot'
          opt.version       = YouPlot::VERSION
          opt.summary_width = 24
          opt.on_tail('') # Add a blank line at the end
          opt.separator('')
          opt.on('Common options:')
          opt.on('-O', '--pass [FILE]', 'file to output input data to [stdout]',
                 'for inserting YouPlot in the middle of Unix pipes') do |v|
            @options[:pass] = v || $stdout
          end
          opt.on('-o', '--output [FILE]', 'file to output plots to [stdout]',
                 'If no option is specified, plot will print to stderr') do |v|
            @options[:output] = v || $stdout
          end
          opt.on('-d', '--delimiter VAL', String, 'use DELIM instead of TAB for field delimiter') do |v|
            @options[:delimiter] = v
          end
          opt.on('-H', '--headers', TrueClass, 'specify that the input has header row') do |v|
            @options[:headers] = v
          end
          opt.on('-T', '--transpose', TrueClass, 'transpose the axes of the input data') do |v|
            @options[:transpose] = v
          end
          opt.on('-t', '--title VAL', String, 'print string on the top of plot') do |v|
            params.title = v
          end
          opt.on('-x', '--xlabel VAL', String, 'print string on the bottom of the plot') do |v|
            params.xlabel = v
          end
          opt.on('-y', '--ylabel VAL', String, 'print string on the far left of the plot') do |v|
            params.ylabel = v
          end
          opt.on('-w', '--width VAL', Integer, 'number of characters per row') do |v|
            params.width = v
          end
          opt.on('-h', '--height VAL', Numeric, 'number of rows') do |v|
            params.height = v
          end
          opt.on('-b', '--border VAL', String, 'specify the style of the bounding box') do |v|
            params.border = v.to_sym
          end
          opt.on('-m', '--margin VAL', Numeric, 'number of spaces to the left of the plot') do |v|
            params.margin = v
          end
          opt.on('-p', '--padding VAL', Numeric, 'space of the left and right of the plot') do |v|
            params.padding = v
          end
          opt.on('-c', '--color VAL', String, 'color of the drawing') do |v|
            params.color = v =~ /\A[0-9]+\z/ ? v.to_i : v.to_sym
          end
          opt.on('--[no-]labels', TrueClass, 'hide the labels') do |v|
            params.labels = v
          end
          opt.on('--progress', TrueClass, 'progressive') do |v|
            @options[:progressive] = v
          end
          opt.on('--encoding VAL', String, 'Specify the input encoding') do |v|
            @options[:encoding] = v
          end
          # Optparse adds the help option, but it doesn't show up in usage.
          # This is why you need the code below.
          opt.on('--help', 'print sub-command help menu') do
            puts opt.help
            exit
          end
          opt.on('--debug', TrueClass, 'print preprocessed data') do |v|
            @options[:debug] = v
          end
          yield opt if block_given?
        end
      end

      def main_parser
        @main_parser ||= create_default_parser do |main_parser|
          # Here, help message is stored in the banner.
          # Because help of main_parser may be referred by `sub_parser`.
          
          main_parser.banner = \
            <<~MSG
              
              Program: YouPlot (Tools for plotting on the terminal)
              Version: #{YouPlot::VERSION} (using UnicodePlot #{UnicodePlot::VERSION})
              Source:  https://github.com/kojix2/youplot

              Usage:   uplot <command> [options] <in.tsv>

              Commands:
                  barplot    bar           draw a horizontal barplot
                  histogram  hist          draw a horizontal histogram
                  lineplot   line          draw a line chart
                  lineplots  lines         draw a line chart with multiple series
                  scatter    s             draw a scatter plot
                  density    d             draw a density plot
                  boxplot    box           draw a horizontal boxplot
                  colors     color         show the list of available colors

                  count      c             draw a baplot based on the number of 
                                           occurrences (slow)
              
              General options:
                  --help                   print command specific help menu
                  --version                print the version of YouPlot 
            MSG

          # Actually, main_parser can take common optional arguments.
          # However, these options dose not be shown in the help menu.
          # I think the main help should be simple.
          main_parser.on('--help', 'print sub-command help menu') do
            puts main_parser.banner
            puts
            exit
          end
        end
      end

      def sub_parser
        @sub_parser ||= create_default_parser do |parser|
          parser.banner = <<~MSG

            Usage: YouPlot #{command} [options] <in.tsv>

            Options for #{command}:
          MSG

          case command

          # If you type only `uplot` in the terminal.
          when nil
            warn main_parser.banner
            warn "\n"
            exit 1

          when :barplot, :bar
            parser.on_head('--symbol VAL', String, 'character to be used to plot the bars') do |v|
              params.symbol = v
            end
            parser.on_head('--xscale VAL', String, 'axis scaling') do |v|
              params.xscale = v
            end
            parser.on_head('--fmt VAL', String, 'xy : header is like x, y...', 'yx : header is like y, x...') do |v|
              @options[:fmt] = v
            end

          when :count, :c
            parser.on_head('--symbol VAL', String, 'character to be used to plot the bars') do |v|
              params.symbol = v
            end

          when :histogram, :hist
            parser.on_head('-n', '--nbins VAL', Numeric, 'approximate number of bins') do |v|
              params.nbins = v
            end
            parser.on_head('--closed VAL', String) do |v|
              params.closed = v
            end
            parser.on_head('--symbol VAL', String, 'character to be used to plot the bars') do |v|
              params.symbol = v
            end

          when :lineplot, :line
            parser.on_head('--canvas VAL', String, 'type of canvas') do |v|
              params.canvas = v
            end
            parser.on_head('--xlim VAL', Array, 'plotting range for the x coordinate') do |v|
              params.xlim = v.take(2)
            end
            parser.on_head('--ylim VAL', Array, 'plotting range for the y coordinate') do |v|
              params.ylim = v.take(2)
            end
            parser.on_head('--fmt VAL', String, 'xy : header is like x, y...', 'yx : header is like y, x...') do |v|
              @options[:fmt] = v
            end

          when :lineplots, :lines
            parser.on_head('--canvas VAL', String) do |v|
              params.canvas = v
            end
            parser.on_head('--xlim VAL', Array, 'plotting range for the x coordinate') do |v|
              params.xlim = v.take(2)
            end
            parser.on_head('--ylim VAL', Array, 'plotting range for the y coordinate') do |v|
              params.ylim = v.take(2)
            end
            parser.on_head('--fmt VAL', String, 'xyxy : header is like x1, y1, x2, y2, x3, y3...',
                           'xyy  : header is like x, y1, y2, y2, y3...') do |v|
              @options[:fmt] = v
            end

          when :scatter, :s
            parser.on_head('--canvas VAL', String) do |v|
              params.canvas = v
            end
            parser.on_head('--xlim VAL', Array, 'plotting range for the x coordinate') do |v|
              params.xlim = v.take(2)
            end
            parser.on_head('--ylim VAL', Array, 'plotting range for the y coordinate') do |v|
              params.ylim = v.take(2)
            end
            parser.on_head('--fmt VAL', String, 'xyxy : header is like x1, y1, x2, y2, x3, y3...',
                           'xyy  : header is like x, y1, y2, y2, y3...') do |v|
              @options[:fmt] = v
            end

          when :density, :d
            parser.on_head('--grid', TrueClass) do |v|
              params.grid = v
            end
            parser.on_head('--xlim VAL', Array, 'plotting range for the x coordinate') do |v|
              params.xlim = v.take(2)
            end
            parser.on_head('--ylim VAL', Array, 'plotting range for the y coordinate') do |v|
              params.ylim = v.take(2)
            end
            parser.on('--fmt VAL', String, 'xyxy : header is like x1, y1, x2, y2, x3, y3...',
                      'xyy  : header is like x, y1, y2, y2, y3...') do |v|
              @options[:fmt] = v
            end

          when :boxplot, :box
            parser.on_head('--xlim VAL', Array, 'plotting range for the x coordinate') do |v|
              params.xlim = v.take(2)
            end

          when :colors, :color, :colours, :colour
            parser.on_head('-n', '--names', 'show color names only', TrueClass) do |v|
              @options[:color_names] = v
            end

          else
            warn "uplot: unrecognized command '#{command}'"
            exit 1
          end
        end
      end

      def parse_options(argv = ARGV)
        begin
          main_parser.order!(argv)
        rescue OptionParser::ParseError => e
          warn "uplot: #{e.message}"
          exit 1
        end

        @command = argv.shift&.to_sym

        begin
          sub_parser.parse!(argv)
        rescue OptionParser::ParseError => e
          warn "uplot: #{e.message}"
          exit 1
        end
      end
    end
  end
end
