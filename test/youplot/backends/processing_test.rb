# frozen_string_literal: true

require_relative '../../test_helper'

class ProcessingTest < Test::Unit::TestCase
  test :count_values do
    @m = YouPlot::Backends::Processing
    assert_equal([%i[a b c], [3, 2, 1]], @m.count_values(%i[a a a b b c]))
    assert_equal([%i[c b a], [3, 2, 1]], @m.count_values(%i[a b b c c c]))
  end

  test :count_values_non_tally do
    @m = YouPlot::Backends::Processing
    assert_equal([%i[a b c], [3, 2, 1]], @m.count_values(%i[a a a b b c], tally: false))
    assert_equal([%i[c b a], [3, 2, 1]], @m.count_values(%i[a b b c c c], tally: false))
  end
end
