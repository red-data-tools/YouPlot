# frozen_string_literal: true

require_relative '../../test_helper'

class YouPlotCommandTest < Test::Unit::TestCase
  test :count_values do
    @m = YouPlot::Backends::Processing
    assert_equal([%i[a b c], [3, 2, 1]], @m.count_values(%i[a a a b b c]))
    assert_equal([%i[c b a], [3, 2, 1]], @m.count_values(%i[a b b c c c]))
  end
end
