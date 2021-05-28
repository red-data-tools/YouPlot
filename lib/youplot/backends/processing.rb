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
          .sort { |a, b| a[1] <=> b[1] }
          .reverse
          .transpose
        # faster than `.sort_by{|a| a[1]}`, `.sort_by(a:last)`
        #             `.sort{ |a, b| -a[1] <=> -b[1] }
      end
    end
  end
end
