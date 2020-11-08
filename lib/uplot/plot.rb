# frozen_string_literal: true

require 'unicode_plot'

module Uplot
  # plotting functions.
  module Plot
    module_function

    def barplot(data, params, count: false)
      headers = data.headers
      series = data.series
      if count
        series = Preprocessing.count_values(series[0])
        params.title = headers[0] if headers
      end
      params.title ||= headers[1] if headers
      labels = series[0].map(&:to_s)
      values = series[1].map(&:to_f)
      UnicodePlot.barplot(labels, values, **params.to_hc)
    end

    def histogram(data, params)
      headers = data.headers
      series = data.series
      params.title ||= data.headers[0] if headers
      values = series[0].map(&:to_f)
      UnicodePlot.histogram(values, **params.to_hc)
    end

    def line(data, params)
      headers = data.headers
      series = data.series
      if series.size == 1
        # If there is only one series, it is assumed to be sequential data.
        params.ylabel ||= headers[0] if headers
        y = series[0].map(&:to_f)
        UnicodePlot.lineplot(y, **params.to_hc)
      else
        # If there are 2 or more series,
        # assume that the first 2 series are the x and y series respectively.
        if headers
          params.xlabel ||= headers[0]
          params.ylabel ||= headers[1]
        end
        x = series[0].map(&:to_f)
        y = series[1].map(&:to_f)
        UnicodePlot.lineplot(x, y, **params.to_hc)
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
      params.ylim ||= series[1..-1].flatten.minmax # why need?
      plot = UnicodePlot.public_send(method1, series[0], series[1], **params.to_hc)
      2.upto(series.size - 1) do |i|
        UnicodePlot.public_send(method2, plot, series[0], series[i], name: headers&.[](i))
      end
      plot
    end

    def plot_xyxy(data, method1, params)
      headers = data.headers
      series = data.series
      method2 = get_method2(method1)
      series.map! { |s| s.map(&:to_f) }
      series = series.each_slice(2).to_a
      params.name ||= headers[0] if headers
      params.xlim = series.map(&:first).flatten.minmax # why need?
      params.ylim = series.map(&:last).flatten.minmax  # why need?
      x1, y1 = series.shift
      plot = UnicodePlot.public_send(method1, x1, y1, **params.to_hc)
      series.each_with_index do |(xi, yi), i|
        UnicodePlot.public_send(method2, plot, xi, yi, name: headers&.[]((i + 1) * 2))
      end
      plot
    end

    def plot_fmt(data, fmt, method1, params)
      case fmt
      when 'xyy'
        plot_xyy(data, method1, params)
      when 'xyxy'
        plot_xyxy(data, method1, params)
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
      UnicodePlot.boxplot(headers, series, **params.to_hc)
    end

    def colors(color_names = false)
      UnicodePlot::StyledPrinter::TEXT_COLORS.each do |k, v|
        print v
        print k
        unless color_names
          print "\t"
          print '  ●'
        end
        print "\033[0m"
        print "\t"
      end
      puts
    end

    def check_series_size(data, fmt)
      series = data.series
      if series.size == 1
        warn 'uplot: There is only one series of input data. Please check the delimiter.'
        warn ''
        warn "  Headers: \e[35m#{data.headers.inspect}\e[0m"
        warn "  The first item is: \e[35m\"#{series[0][0]}\"\e[0m"
        warn "  The last item is : \e[35m\"#{series[0][-1]}\"\e[0m"
        exit 1
      end
      if fmt == 'xyxy' && series.size.odd?
        warn 'uplot: In the xyxy format, the number of series must be even.'
        warn ''
        warn "  Number of series: \e[35m#{series.size}\e[0m"
        warn "  Headers: \e[35m#{data.headers.inspect}\e[0m"
        exit 1
      end
    end
  end
end
