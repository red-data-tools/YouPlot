# frozen_string_literal: true

require 'optparse'
require_relative 'options'

module YouPlot
  # Class for parsing command line options
  class Parser
    class Error < StandardError; end

    attr_reader :command, :options, :params,
                :main_parser, :sub_parser,
                :config_file, :config

    def initialize
      @command = nil

      @options = Options.new(
        "\t",    # elimiter:
        false,   # transpose:
        nil,     # headers:
        false,   # pass:
        $stderr, # output:
        'xyy',   # fmt:
        false,   # progressive:
        nil,     # encoding:
        false,   # color_names:
        false    # debug:
      )

      @params = Parameters.new
    end

    def apply_config_file
      return if !config_file && find_config_file.nil?

      read_config_file
      configure
    end

    def config_file_candidate_paths
      # keep the order of the paths
      paths = []
      paths << ENV['MYYOUPLOTRC'] if ENV['MYYOUPLOTRC']
      paths << '.youplot.yml'
      paths << '.youplotrc'
      if ENV['HOME']
        paths << File.join(ENV['HOME'], '.youplotrc')
        paths << File.join(ENV['HOME'], '.youplot.yml')
        paths << File.join(ENV['HOME'], '.config', 'youplot', 'youplotrc')
        paths << File.join(ENV['HOME'], '.config', 'youplot', 'youplot.yml')
      end
      paths
    end

    def find_config_file
      config_file_candidate_paths.each do |file|
        path = File.expand_path(file)
        next unless File.exist?(path)

        @config_file = path
        ENV['MYYOUPLOTRC'] = path
        return @config_file
      end
      nil
    end

    def read_config_file
      require 'yaml'
      @config = YAML.load_file(config_file)
    end

    def configure
      option_members = @options.members
      param_members = @params.members
      # It would be more useful to be able to configure by plot type
      config.each do |k, v|
        k = k.to_sym
        if option_members.include?(k)
          @options[k] ||= v
        elsif param_members.include?(k)
          @params[k] ||= v
        else
          raise Error, "Unknown option/param in config file: #{k}"
        end
      end
    end

    def create_base_parser
      OptionParser.new do |parser|
        parser.program_name  = 'YouPlot'
        parser.version       = YouPlot::VERSION
        parser.summary_width = 23
        parser.on_tail('') # Add a blank line at the end
        parser.separator('')
        parser.on('Common options:')
        parser.on('-O', '--pass [FILE]', 'file to output input data to [stdout]',
                  'for inserting YouPlot in the middle of Unix pipes') do |v|
          options[:pass] = v || $stdout
        end
        parser.on('-o', '--output [FILE]', 'file to output plots to [stdout]',
                  'If no option is specified, plot will print to stderr') do |v|
          options[:output] = v || $stdout
        end
        parser.on('-d', '--delimiter DELIM', String, 'use DELIM instead of [TAB] for field delimiter') do |v|
          options[:delimiter] = v
        end
        parser.on('-H', '--headers', TrueClass, 'specify that the input has header row') do |v|
          options[:headers] = v
        end
        parser.on('-T', '--transpose', TrueClass, 'transpose the axes of the input data') do |v|
          options[:transpose] = v
        end
        parser.on('-t', '--title STR', String, 'print string on the top of plot') do |v|
          params.title = v
        end
        parser.on('--xlabel STR', String, 'print string on the bottom of the plot') do |v|
          params.xlabel = v
        end
        parser.on('--ylabel STR', String, 'print string on the far left of the plot') do |v|
          params.ylabel = v
        end
        parser.on('-w', '--width INT', Numeric, 'number of characters per row') do |v|
          params.width = v
        end
        parser.on('-h', '--height INT', Numeric, 'number of rows') do |v|
          params.height = v
        end
        border_options = UnicodePlot::BORDER_MAP.keys.join(', ')
        parser.on('-b', '--border STR', String, 'specify the style of the bounding box', "(#{border_options})") do |v|
          params.border = v.to_sym
        end
        parser.on('-m', '--margin INT', Numeric, 'number of spaces to the left of the plot') do |v|
          params.margin = v
        end
        parser.on('--padding INT', Numeric, 'space of the left and right of the plot') do |v|
          params.padding = v
        end
        parser.on('-c', '--color VAL', String, 'color of the drawing') do |v|
          params.color = v =~ /\A[0-9]+\z/ ? v.to_i : v.to_sym
        end
        parser.on('--[no-]labels', TrueClass, 'hide the labels') do |v|
          params.labels = v
        end
        parser.on('-p', '--progress', TrueClass, 'progressive mode [experimental]') do |v|
          options[:progressive] = v
        end
        parser.on('-C', '--color-output', TrueClass, 'colorize even if writing to a pipe') do |_v|
          UnicodePlot::IOContext.define_method(:color?) { true } # FIXME
        end
        parser.on('-M', '--monochrome', TrueClass, 'no colouring even if writing to a tty') do |_v|
          UnicodePlot::IOContext.define_method(:color?) { false } # FIXME
        end
        parser.on('--encoding STR', String, 'specify the input encoding') do |v|
          options[:encoding] = v
        end
        # Optparse adds the help option, but it doesn't show up in usage.
        # This is why you need the code below.
        parser.on('--help', 'print sub-command help menu') do
          puts parser.help
          exit if YouPlot.run_as_executable?
        end
        parser.on('--config FILE', 'specify a config file') do |v|
          @config_file = v
        end
        parser.on('--debug', TrueClass, 'print preprocessed data') do |v|
          options[:debug] = v
        end
        # yield opt if block_given?
      end
    end

    def create_main_parser
      @main_parser = create_base_parser
      main_parser.banner = \
        <<~MSG

          Program: YouPlot (Tools for plotting on the terminal)
          Version: #{YouPlot::VERSION} (using UnicodePlot #{UnicodePlot::VERSION})
          Source:  https://github.com/red-data-tools/YouPlot

          Usage:   uplot <command> [options] <in.tsv>

          Commands:
              barplot    bar           draw a horizontal barplot
              histogram  hist          draw a horizontal histogram
              lineplot   line          draw a line chart
              lineplots  lines         draw a line chart with multiple series
              scatter    s             draw a scatter plot
              density    d             draw a density plot
              boxplot    box           draw a horizontal boxplot
              count      c             draw a baplot based on the number of
                                       occurrences (slow)
              colors     color         show the list of available colors

          General options:
              --config                 print config file info
              --help                   print command specific help menu
              --version                print the version of YouPlot
        MSG

      # Help for the main parser is simple.
      # Simply show the banner above.
      main_parser.on('--help', 'print sub-command help menu') do
        show_main_help
      end

      main_parser.on('--config', 'show config file info') do
        show_config_info
      end
    end

    def show_main_help(out = $stdout)
      out.puts main_parser.banner
      out.puts
      exit if YouPlot.run_as_executable?
    end

    def show_config_info
      if ENV['MYYOUPLOTRC']
        puts "config file : #{ENV['MYYOUPLOTRC']}"
        puts config.inspect
      else
        puts <<~EOS
          Configuration file not found.
          It should be a YAML file, like this example:
            width : 40
            height : 20
          By default, YouPlot will look for the configuration file in these locations:
          #{config_file_candidate_paths.map { |s| '  ' + s }.join("\n")}
          If you have the file elsewhere, you can specify its location with the `MYYOUPLOTRC` environment variable.
        EOS
      end
      exit if YouPlot.run_as_executable?
    end

    def sub_parser_add_symbol
      sub_parser.on_head('--symbol STR', String, 'character to be used to plot the bars') do |v|
        params.symbol = v
      end
    end

    def sub_parser_add_xscale
      xscale_options = UnicodePlot::ValueTransformer::PREDEFINED_TRANSFORM_FUNCTIONS.keys.join(', ')
      sub_parser.on_head('--xscale STR', String, "axis scaling (#{xscale_options})") do |v|
        params.xscale = v.to_sym
      end
    end

    def sub_parser_add_canvas
      canvas_types = UnicodePlot::Canvas::CANVAS_CLASS_MAP.keys.join(', ')
      sub_parser.on_head('--canvas STR', String, 'type of canvas', "(#{canvas_types})") do |v|
        params.canvas = v.to_sym
      end
    end

    def sub_parser_add_xlim
      sub_parser.on_head('--xlim FLOAT,FLOAT', Array, 'plotting range for the x coordinate') do |v|
        params.xlim = v.map(&:to_f)
      end
    end

    def sub_parser_add_ylim
      sub_parser.on_head('--ylim FLOAT,FLOAT', Array, 'plotting range for the y coordinate') do |v|
        params.ylim = v.map(&:to_f)
      end
    end

    def sub_parser_add_grid
      sub_parser.on_head('--[no-]grid', TrueClass, 'draws grid-lines at the origin') do |v|
        params.grid = v
      end
    end

    def sub_parser_add_fmt_xyxy
      sub_parser.on_head('--fmt STR', String,
                         'xyxy : header is like x1, y1, x2, y2, x3, y3...',
                         'xyy  : header is like x, y1, y2, y2, y3...') do |v|
        options[:fmt] = v
      end
    end

    def sub_parser_add_fmt_yx
      sub_parser.on_head('--fmt STR', String,
                         'xy : header is like x, y...',
                         'yx : header is like y, x...') do |v|
        options[:fmt] = v
      end
    end

    def create_sub_parser
      @sub_parser = create_base_parser
      sub_parser.banner = \
        <<~MSG

          Usage: YouPlot #{command} [options] <in.tsv>

          Options for #{command}:
        MSG

      case command

      # If you type only `uplot` in the terminal.
      # Output help to standard error output.
      when nil
        show_main_help($stderr)

      # Output help to standard output.
      when :help
        show_main_help

      when :barplot, :bar
        sub_parser_add_symbol
        sub_parser_add_fmt_yx
        sub_parser_add_xscale

      when :count, :c
        sub_parser.on_head('-r', '--reverse', TrueClass, 'reverse the result of comparisons') do |v|
          options.reverse = v
        end
        sub_parser_add_symbol
        sub_parser_add_xscale

      when :histogram, :hist
        sub_parser_add_symbol
        sub_parser.on_head('--closed STR', String, 'side of the intervals to be closed [left]') do |v|
          params.closed = v
        end
        sub_parser.on_head('-n', '--nbins INT', Numeric, 'approximate number of bins') do |v|
          params.nbins = v
        end

      when :lineplot, :line, :l
        sub_parser_add_canvas
        sub_parser_add_grid
        sub_parser_add_fmt_yx
        sub_parser_add_ylim
        sub_parser_add_xlim

      when :lineplots, :lines, :ls
        sub_parser_add_canvas
        sub_parser_add_grid
        sub_parser_add_fmt_xyxy
        sub_parser_add_ylim
        sub_parser_add_xlim

      when :scatter, :s
        sub_parser_add_canvas
        sub_parser_add_grid
        sub_parser_add_fmt_xyxy
        sub_parser_add_ylim
        sub_parser_add_xlim

      when :density, :d
        sub_parser_add_canvas
        sub_parser_add_grid
        sub_parser_add_fmt_xyxy
        sub_parser_add_ylim
        sub_parser_add_xlim

      when :boxplot, :box
        sub_parser_add_xlim

      when :colors, :color, :colours, :colour
        sub_parser.on_head('-n', '--names', TrueClass, 'show color names only') do |v|
          options[:color_names] = v
        end

      # Currently it simply displays the configuration file,
      # but in the future this may be changed to open a text editor like Vim
      # to edit the configuration file.
      when :config
        show_config_info

      else
        error_message = "YouPlot: unrecognized command '#{command}'"
        raise Error, error_message unless YouPlot.run_as_executable?

        warn error_message
        exit 1

      end
    end

    def parse_options(argv = ARGV)
      begin
        create_main_parser.order!(argv)
      rescue OptionParser::ParseError => e
        warn "YouPlot: #{e.message}"
        exit 1 if YouPlot.run_as_executable?
      end

      @command = argv.shift&.to_sym

      begin
        create_sub_parser&.parse!(argv)
      rescue OptionParser::ParseError => e
        warn "YouPlot: #{e.message}"
        exit 1 if YouPlot.run_as_executable?
      end

      begin
        apply_config_file
      rescue StandardError => e
        warn "YouPlot: #{e.message}"
        exit 1 if YouPlot.run_as_executable?
      end
    end
  end
end
