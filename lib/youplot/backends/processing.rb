# frozen_string_literal: true

module YouPlot
  # plotting functions.
  module Backends
    module Processing
      module_function

      def count_values(arr)
        # tally was added in Ruby 2.7
        if Enumerable.method_defined? :tally
          arr.tally
        else
          # https://github.com/marcandre/backports
          arr.each_with_object(Hash.new(0)) { |item, res| res[item] += 1 }
             .tap { |h| h.default = nil }
        end
          .sort { |a, b| a[1] <=> b[1] }
          .reverse
          .transpose
      end
    end
  end
end
