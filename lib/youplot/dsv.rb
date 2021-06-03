# frozen_string_literal: true

require 'csv'

module YouPlot
  # Module to handle DSV (Delimiter-separated values) format.
  # Extract header and series.
  module DSV
    module_function

    def parse(input, delimiter, headers, transpose)
      # Parse as CSV
      arr = CSV.parse(input, col_sep: delimiter)

      # Remove blank lines
      arr.delete_if do |i|
        i == [] or i.all?(&:nil?)
      end

      # get header
      headers = get_headers(arr, headers, transpose)

      # get series
      series = get_series(arr, headers, transpose)

      # Return if No header
      return Data.new(headers, series) if headers.nil?

      # Warn if header contains nil
      warn "\e[35mHeaders contains nil in it.\e[0m" if headers.include?(nil)

      # Warn if header contains ''
      warn "\e[35mHeaders contains \"\" in it.\e[0m" if headers.include? ''

      # Make sure the number of elements in the header matches the number of series.
      h_size = headers.size
      s_size = series.size

      if h_size > s_size
        warn "\e[35mThe number of headers is greater than the number of series.\e[0m"
        exit 1 if YouPlot.run_as_executable?

      elsif h_size < s_size
        warn "\e[35mThe number of headers is less than the number of series.\e[0m"
        exit 1 if YouPlot.run_as_executable?
      end

      Data.new(headers, series) if h_size == s_size
    end

    # Transpose different sized ruby arrays
    # https://stackoverflow.com/q/26016632
    def transpose2(arr)
      Array.new(arr.map(&:length).max) { |i| arr.map { |e| e[i] } }
    end

    def get_headers(arr, headers, transpose)
      # header(-)
      return nil unless headers

      # header(+) trenspose(+)
      return arr.map(&:first) if transpose

      # header(+) transpose(-)
      arr[0]
    end

    def get_series(arr, headers, transpose)
      # header(-)
      unless headers
        return arr if transpose

        return transpose2(arr)
      end

      # header(+) but no element in the series.
      # TODO: should raise error?
      return Array.new(arr[0].size, []) if arr.size == 1

      # header(+) transpose(+)
      return arr.map { |row| row[1..-1] } if transpose

      # header(+) transpose(-)
      transpose2(arr[1..-1])
    end
  end
end
