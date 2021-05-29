# frozen_string_literal: true

module YouPlot
  # plotting functions.
  module Backends
    module Processing
      module_function

      def count_values(arr, tally: true)
        # tally was added in Ruby 2.7
        if tally && Enumerable.method_defined?(:tally)
          arr.tally
        else
          # value_counts Enumerable::Statistics
          arr.value_counts(dropna: false)
        end
          .sort do |a, b|
            # compare values
            r = b[1] <=> a[1]
            # If the values are the same, compare by name
            r = a[0] <=> b[0] if r == 0
            r
          end
          .transpose
      end
    end
  end
end
