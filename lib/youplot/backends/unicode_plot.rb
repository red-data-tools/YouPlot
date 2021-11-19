# frozen_string_literal: true

# UnicodePlot - Plot your data by Unicode characters
# https://github.com/red-data-tools/unicode_plot.rb

require_relative 'processing'
require 'unicode_plot'

# If the line color is specified as a number, the program will display an error
# message to the user and exit. Remove this patch when UnicodePlot is improved.

module UnicodePlot
  class << self
    alias lineplot_original lineplot
    def lineplot(*args, **kw)
      if kw[:color].is_a? Numeric
        warn <<~EOS
          YouPlot: Line colors cannot be specified by numerical values.

          For more information, please see the following issue.
          https://github.com/red-data-tools/unicode_plot.rb/issues/34
        EOS
        YouPlot.run_as_executable ? exit(1) : raise(Error)
      end
      lineplot_original(*args, **kw)
    end
  end
end

module YouPlot
  # plotting functions.
  module Backends
    module UnicodePlot
      class Error < StandardError; end

      module_function

      def barplot(data, params, fmt = nil, count: false, reverse: false)
        headers = data.headers
        series = data.series
        # `uplot count`
        if count
          series = Processing.count_values(series[0], reverse: reverse)
          params.title = headers[0] if headers
        end
        if series.size == 1
          # If there is only one series.use the line number for label.
          params.title ||= headers[0] if headers
          labels = Array.new(series[0].size) { |i| (i + 1).to_s }
          values = series[0].map(&:to_f)
        else
          # If there are 2 or more series...
          if fmt == 'yx'
            # assume that the first 2 series are the y and x series respectively.
            x_col = 1
            y_col = 0
          else
            # assume that the first 2 series are the x and y series respectively.
            x_col = 0
            y_col = 1
          end
          params.title ||= headers[y_col] if headers
          labels = series[x_col]
          values = series[y_col].map(&:to_f)
        end
        ::UnicodePlot.barplot(labels, values, **params.to_hc)
      end

      def histogram(data, params)
        headers = data.headers
        series = data.series
        params.title ||= data.headers[0] if headers
        values = series[0].map(&:to_f)
        ::UnicodePlot.histogram(values, **params.to_hc)
      end

      def line(data, params, fmt = nil)
        headers = data.headers
        series = data.series
        if series.size == 1
          # If there is only one series, it is assumed to be sequential data.
          params.ylabel ||= headers[0] if headers
          y = series[0].map(&:to_f)
          ::UnicodePlot.lineplot(y, **params.to_hc)
        else
          # If there are 2 or more series...
          if fmt == 'yx'
            # assume that the first 2 series are the y and x series respectively.
            x_col = 1
            y_col = 0
          else
            # assume that the first 2 series are the x and y series respectively.
            x_col = 0
            y_col = 1
          end
          if headers
            params.xlabel ||= headers[x_col]
            params.ylabel ||= headers[y_col]
          end
          x = series[x_col].map(&:to_f)
          y = series[y_col].map(&:to_f)
          ::UnicodePlot.lineplot(x, y, **params.to_hc)
        end
      end

      def get_method2(method1)
        "#{method1}!".to_sym
      end

      def plot_xyy(data, method1, params)
        headers = data.headers
        series = data.series
        method2 = get_method2(method1)
        series.map! { |s| s.map(&:to_f) }
        if headers
          params.name   ||= headers[1]
          params.xlabel ||= headers[0]
        end
        params.xlim ||= series[0].flatten.minmax # why need?
        params.ylim ||= series[1..-1].flatten.minmax # why need?
        plot = ::UnicodePlot.public_send(method1, series[0], series[1], **params.to_hc)
        2.upto(series.size - 1) do |i|
          ::UnicodePlot.public_send(method2, plot, series[0], series[i], name: headers&.[](i))
        end
        plot
      end

      def plot_xyxy(data, method1, params)
        headers = data.headers
        series2 = data.series
                      .map { |s| s.map(&:to_f) }
                      .each_slice(2).to_a
        method2 = get_method2(method1)
        params.name ||= headers[0] if headers
        params.xlim ||= series2.map(&:first).flatten.minmax # why need?
        params.ylim ||= series2.map(&:last).flatten.minmax # why need?
        x1, y1 = series2.shift
        plot = ::UnicodePlot.public_send(method1, x1, y1, **params.to_hc)
        series2.each_with_index do |(xi, yi), i|
          ::UnicodePlot.public_send(method2, plot, xi, yi, name: headers&.[]((i + 1) * 2))
        end
        plot
      end

      def plot_fmt(data, fmt, method1, params)
        case fmt
        when 'xyy'
          plot_xyy(data, method1, params)
        when 'xyxy'
          plot_xyxy(data, method1, params)
        when 'yx'
          raise "Incorrect format: #{fmt}"
        else
          raise "Unknown format: #{fmt}"
        end
      end

      def lines(data, params, fmt = 'xyy')
        check_series_size(data, fmt)
        plot_fmt(data, fmt, :lineplot, params)
      end

      def scatter(data, params, fmt = 'xyy')
        check_series_size(data, fmt)
        plot_fmt(data, fmt, :scatterplot, params)
      end

      def density(data, params, fmt = 'xyy')
        check_series_size(data, fmt)
        plot_fmt(data, fmt, :densityplot, params)
      end

      def boxplot(data, params)
        headers = data.headers
        series = data.series
        headers ||= (1..series.size).map(&:to_s)
        series.map! { |s| s.map(&:to_f) }
        ::UnicodePlot.boxplot(headers, series, **params.to_hc)
      end

      def colors(color_names = false)
        # FIXME
        s = String.new
        ::UnicodePlot::StyledPrinter::TEXT_COLORS.each do |k, v|
          s << v
          s << k.to_s
          unless color_names
            s << "\t"
            s << '  ●'
          end
          s << "\033[0m"
          s << "\t"
        end
        s << "\n"
        def s.render(obj)
          obj.print(self)
        end
        s
      end

      def check_series_size(data, fmt)
        series = data.series
        if series.size == 1
          warn <<~EOS
            YouPlot: There is only one series of input data. Please check the delimiter.

            Headers: \e[35m#{data.headers.inspect}\e[0m
            The first item is: \e[35m\"#{series[0][0]}\"\e[0m
            The last item is : \e[35m\"#{series[0][-1]}\"\e[0m
          EOS
          # NOTE: Error messages cannot be colored.
          YouPlot.run_as_executable ? exit(1) : raise(Error)
        end
        if fmt == 'xyxy' && series.size.odd?
          warn <<~EOS
            YouPlot: In the xyxy format, the number of series must be even.

            Number of series: \e[35m#{series.size}\e[0m
            Headers: \e[35m#{data.headers.inspect}\e[0m
          EOS
          # NOTE: Error messages cannot be colored.
          YouPlot.run_as_executable ? exit(1) : raise(Error)
        end
      end
    end
  end
end
