# frozen_string_literal: true

require 'optparse'
require_relative 'params'

module Uplot
  class Command
    class Parser
      attr_reader :command, :params, :main_parser, :sub_parsers,
                  :delimiter, :transpose, :headers, :output, :count, :fmt, :debug

      def initialize
        @sub_parsers = create_sub_parsers
        @main_parser = create_main_parser
        @command = nil
        @params = Params.new

        @delimiter  = "\t"
        @transpose  = false
        @headers    = nil
        @output     = false
        @count      = false
        @fmt        = 'xyy'
        @debug      = false
      end

      def create_default_parser
        OptionParser.new do |opt|
          opt.program_name = 'uplot'
          opt.version = Uplot::VERSION
          opt.on('-O', '--output', TrueClass) do |v|
            @output = v
          end
          opt.on('-d', '--delimiter VAL', 'use DELIM instead of TAB for field delimiter', String) do |v|
            @delimiter = v
          end
          opt.on('-H', '--headers', 'specify that the input has header row', TrueClass) do |v|
            @headers = v
          end
          opt.on('-T', '--transpose', TrueClass) do |v|
            @transpose = v
          end
          opt.on('-t', '--title VAL', 'print string on the top of plot', String) do |v|
            params.title = v
          end
          opt.on('-x', '--xlabel VAL', 'print string on the bottom of the plot', String) do |v|
            params.xlabel = v
          end
          opt.on('-y', '--ylabel VAL', 'print string on the far left of the plot', String) do |v|
            params.ylabel = v
          end
          opt.on('-w', '--width VAL', 'number of characters per row', Integer) do |v|
            params.width = v
          end
          opt.on('-h', '--height VAL', 'number of rows', Numeric) do |v|
            params.height = v
          end
          opt.on('-b', '--border VAL', 'specify the style of the bounding box', String) do |v|
            params.border = v.to_sym
          end
          opt.on('-m', '--margin VAL', 'number of spaces to the left of the plot', Numeric) do |v|
            params.margin = v
          end
          opt.on('-p', '--padding VAL', 'space of the left and right of the plot', Numeric) do |v|
            params.padding = v
          end
          opt.on('-c', '--color VAL', 'color of the drawing', String) do |v|
            params.color = v =~ /\A[0-9]+\z/ ? v.to_i : v.to_sym
          end
          opt.on('--[no-]labels', 'hide the labels', TrueClass) do |v|
            params.labels = v
          end
          opt.on('--fmt VAL', 'xyy, xyxy', String) do |v|
            @fmt = v
          end
          opt.on('--debug', TrueClass) do |v|
            @debug = v
          end
          yield opt if block_given?
        end
      end

      def create_sub_parsers
        parsers = Hash.new do |h, k|
          h[k] = create_default_parser do |parser|
            parser.banner = <<~MSG
              Usage: uplot #{k} [options]

              Options:
            MSG
          end
        end

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
          .on('--xlim VAL', Array) do |v|
            params.xlim = v.take(2)
          end
          .on('--ylim VAL', Array) do |v|
            params.ylim = v.take(2)
          end

        parsers[:lineplots] = \
          parsers[:lines]
          .on('--canvas VAL', String) do |v|
            params.canvas = v
          end
          .on('--xlim VAL', Array) do |v|
            params.xlim = v.take(2)
          end
          .on('--ylim VAL', Array) do |v|
            params.ylim = v.take(2)
          end

        parsers[:scatter] = \
          parsers[:s]
          .on('--canvas VAL', String) do |v|
            params.canvas = v
          end
          .on('--xlim VAL', Array) do |v|
            params.xlim = v.take(2)
          end
          .on('--ylim VAL', Array) do |v|
            params.ylim = v.take(2)
          end

        parsers[:density] = \
          parsers[:d]
          .on('--grid', TrueClass) do |v|
            params.grid = v
          end
          .on('--xlim VAL', Array) do |v|
            params.xlim = v.take(2)
          end
          .on('--ylim VAL', Array) do |v|
            params.ylim = v.take(2)
          end

        parsers[:boxplot] = \
          parsers[:box]
          .on('--xlim VAL', Array) do |v|
            params.xlim = v.take(2)
          end

        parsers[:colors]
          .on('-n', '--names', TrueClass) do |v|
            @color_names = v
          end

        # Preventing the generation of new sub-commands
        parsers.default = nil
        parsers
      end

      def create_main_parser
        create_default_parser do |main_parser|
          # Usage and help messages
          main_parser.banner = \
            <<~MSG
              Program: uplot (Tools for plotting on the terminal)
              Version: #{Uplot::VERSION} (using unicode_plot #{UnicodePlot::VERSION})

              Usage:   uplot <command> [options]

              Command:
                  #{sub_parsers.keys.join("\n    ")}

              Options:
            MSG
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

        unless sub_parsers.key?(command)
          if command.nil?
            warn main_parser.help
          else
            warn "uplot: unrecognized command '#{command}'"
          end
          exit 1
        end
        parser = sub_parsers[command]

        begin
          parser.parse!(argv) unless argv.empty?
        rescue OptionParser::ParseError => e
          warn "uplot: #{e.message}"
          exit 1
        end
      end
    end
  end
end
