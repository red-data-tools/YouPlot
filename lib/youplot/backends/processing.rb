# frozen_string_literal: true

require 'enumerable/statistics'

module YouPlot
  # plotting functions.
  module Backends
    module Processing
      module_function

      def count_values(arr, tally: true)
        a = arr.value_counts
        [a.keys, a.values]
      end
    end
  end
end
