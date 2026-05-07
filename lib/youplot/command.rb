# frozen_string_literal: true

require 'tempfile'
require 'stringio'

require_relative 'dsv'
require_relative 'parser'

require_relative 'backends/unicode_plot'

module YouPlot
  Data = Struct.new(:headers, :series)

  class Command
    attr_accessor :command, :params, :options
    attr_reader :data, :parser

    def initialize(argv = ARGV)
      @argv    = argv
      @parser  = Parser.new
      @command = nil
      @params  = nil
      @options = nil
      @backend = YouPlot::Backends::UnicodePlot
    end

    def run_as_executable
      YouPlot.run_as_executable = true
      run
    end

    def run
      parser.parse_options(@argv)
      @command ||= parser.command
      @options ||= parser.options
      @params  ||= parser.params

      # color command
      if %i[colors color colours colour].include? @command
        plot = create_plot
        output_plot(plot)
        return
      end

      # progressive mode
      if options[:progressive]
        run_progressive

      # normal mode
      else
        # Sometimes the input file does not end with a newline code.
        begin
          begin
            input = Kernel.gets(nil)
          rescue Errno::ENOENT => e
            warn e.message
            next
          end
          main(input)
        end until input
      end
    end

    private

    def run_progressive
      out = progressive_output
      stop = false
      Signal.trap(:INT) { stop = true }

      # make cursor invisible
      out.print "\e[?25l"

      # mainloop
      begin
        while (input = Kernel.gets)
          n = main_progressive(input)
          break if stop

          out.print "\e[#{n}F" if n && n > 0
        end
      ensure
        sanitize_progressive_output(out)
      end
    end

    def progressive_output
      out = options[:output]
      raise 'In progressive mode, output to a file is not possible.' if out.is_a?(String)
      return out if out.respond_to?(:print) && out.respond_to?(:flush)

      raise 'In progressive mode, output to a file is not possible.'
    end

    def sanitize_progressive_output(out = progressive_output)
      out.print "\e[0J"
      # make cursor visible
      out.print "\e[?25h"
    end

    def main(input)
      # Outputs input data to a file or stdout.
      output_data(input)

      @data = parse_dsv(input)

      # Debug mode, show parsed results
      pp @data if options[:debug]

      # When run as a program instead of a library
      if YouPlot.run_as_executable?
        begin
          plot = create_plot
        rescue ArgumentError => e
          # Show only one line of error.
          warn e.backtrace[0]
          # Show error message in purple
          warn "\e[35m#{e}\e[0m"
          # Explicitly terminated with exit code: 1
          exit 1
        end

      # When running YouPlot as a library (e.g. for testing)
      else
        plot = create_plot
      end

      output_plot(plot)
    end

    def main_progressive(input)
      output_data(input)

      row = parse_progressive_row(input)
      return 0 if row.nil?

      @data = progressive_update_data(row)
      return 0 if @data.nil?

      plot = create_plot
      output_plot_progressive(plot)
    end

    def parse_progressive_row(input)
      line = normalize_input_encoding!(input)

      begin
        row = CSV.parse_line(line, col_sep: options[:delimiter])
      rescue CSV::MalformedCSVError => e
        warn 'Failed to parse the text. '
        warn 'Please try to set the correct character encoding with --encoding option.'
        warn e.backtrace.grep(/youplot/).first
        exit 1
      rescue ArgumentError => e
        warn 'Failed to parse the text. '
        warn e.backtrace.grep(/youplot/).first
        exit 1
      end

      return nil if row.nil? || row.empty? || row.all?(&:nil?)

      row
    end

    def progressive_update_data(row)
      init_progressive_state

      return nil if consume_progressive_header?(row)

      append_progressive_row(row)
      progressive_data
    end

    def init_progressive_state
      return if @progressive_initialized

      @progressive_initialized = true
      @progressive_headers = options[:headers] ? [] : nil
      @progressive_series = []
      @progressive_header_consumed = false
      @progressive_row_count = 0
    end

    def consume_progressive_header?(row)
      return false unless options[:headers]
      return false if options[:transpose]
      return false if @progressive_header_consumed

      @progressive_headers = row
      @progressive_header_consumed = true
      true
    end

    def append_progressive_row(row)
      if options[:headers] && options[:transpose]
        @progressive_headers << row[0]
        @progressive_series << row[1..-1]
      elsif options[:transpose]
        @progressive_series << row
      else
        append_progressive_columns(row)
      end
    end

    def progressive_data
      DSV.build_data(@progressive_headers, @progressive_series)
    end

    def append_progressive_columns(row)
      if row.size > @progressive_series.size
        (@progressive_series.size...row.size).each do |i|
          @progressive_series[i] = Array.new(@progressive_row_count, nil)
        end
      end

      0.upto(@progressive_series.size - 1) do |i|
        @progressive_series[i] << row[i]
      end

      @progressive_row_count += 1
    end

    def parse_dsv(input)
      # If encoding is specified, convert to UTF-8
      normalize_input_encoding!(input)

      begin
        data = DSV.parse(input, options[:delimiter], options[:headers], options[:transpose])
      rescue CSV::MalformedCSVError => e
        warn 'Failed to parse the text. '
        warn 'Please try to set the correct character encoding with --encoding option.'
        warn e.backtrace.grep(/youplot/).first
        exit 1
      rescue ArgumentError => e
        warn 'Failed to parse the text. '
        warn e.backtrace.grep(/youplot/).first
        exit 1
      end

      data
    end

    def normalize_input_encoding!(input)
      return input unless options[:encoding]

      input.force_encoding(options[:encoding])
           .encode!('utf-8')
    end

    def create_plot
      case command
      when :bar, :barplot
        @backend.barplot(data, params, options[:fmt])
      when :count, :c
        @backend.barplot(data, params, count: true, reverse: options[:reverse])
      when :hist, :histogram
        @backend.histogram(data, params)
      when :line, :lineplot, :l
        @backend.line(data, params, options[:fmt])
      when :lines, :lineplots, :ls
        @backend.lines(data, params, options[:fmt])
      when :scatter, :s
        @backend.scatter(data, params, options[:fmt])
      when :density, :d
        @backend.density(data, params, options[:fmt])
      when :box, :boxplot
        @backend.boxplot(data, params)
      when :colors, :color, :colours, :colour
        @backend.colors(options[:color_names])
      else
        raise "unrecognized plot_type: #{command}"
      end
    end

    def output_data(input)
      # Pass the input to subsequent pipelines
      out = options[:pass]
      # Handle Tempfile first to keep tests and behavior consistent.
      # Ruby 2.7 Tempfile is Delegator-based and does not match IO/File checks.
      # Then handle path strings and IO-like objects.
      case out
      when Tempfile
        # Keep file descriptor state consistent with the Tempfile object.
        out.truncate(0)   # clear existing content
        out.rewind        # move pointer to the beginning
        out.print(input)  # write new content
        out.flush         # flush buffered writes before immediate read
        out.rewind        # move pointer back to the beginning for out.read
      when String
        File.open(out, 'w') do |f|
          f.print(input)
        end
      else
        out.print(input) if out.respond_to?(:print)
      end
    end

    def output_plot(plot)
      out = options[:output]
      # Handle Tempfile first to keep tests and behavior consistent.
      # Ruby 2.7 Tempfile is Delegator-based and does not match IO/File checks.
      # Then handle path strings and IO-like objects.
      case out
      when Tempfile
        # Keep file descriptor state consistent with the Tempfile object.
        out.truncate(0)   # clear existing content
        out.rewind        # move pointer to the beginning
        plot.render(out)  # write new content
        out.flush         # flush buffered writes before immediate read
        out.rewind        # move pointer back to the beginning for out.read
      when String
        File.open(out, 'w') do |f|
          plot.render(f)
        end
      else
        plot.render(out) if out.respond_to?(:write)
      end
    end

    def output_plot_progressive(plot)
      target = progressive_output

      # RefactorMe
      out = StringIO.new(String.new)
      def out.tty?
        true
      end
      plot.render(out)
      lines = out.string.lines
      lines.each do |line|
        target.print line.chomp
        target.print "\e[0K"
        target.puts
      end
      target.print "\e[0J"
      target.flush
      lines.size
    end
  end
end
