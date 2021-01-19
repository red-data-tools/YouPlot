# frozen_string_literal: true

require_relative '../test_helper'

class YouPlotDSVTest < Test::Unit::TestCase
  def setup
    @m = YouPlot::DSV
  end

  test :transpose2 do
    n = nil

    assert_equal([[1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9]], @m.transpose2([[1, 4, 7],
                                             [2, 5, 8],
                                             [3, 6, 9]]))
    assert_equal([[1, 2, 3],
                  [4, 5, n],
                  [6, n, n]], @m.transpose2([[1, 4, 6],
                                             [2, 5],
                                             [3]]))
    assert_equal([[1, 2, 3],
                  [n, 4, 5],
                  [n, n, 6]], @m.transpose2([[1],
                                             [2, 4],
                                             [3, 5, 6]]))
  end

  test :get_headers do
    assert_equal([1, 4, 7], @m.get_headers([[1, 2, 3],
                                            [4, 5, 6],
                                            [7, 8, 9]], true, true))

    assert_equal([1, 2, 3], @m.get_headers([[1, 4, 6],
                                            [2, 5],
                                            [3]], true, true))

    assert_equal([1, 2, 3], @m.get_headers([[1],
                                            [2, 4],
                                            [3, 5, 6]], true, true))

    assert_equal([1, 2, 3], @m.get_headers([[1, 2, 3],
                                            [4, 5, 6],
                                            [7, 8, 9]], true, false))

    assert_equal([1, 4, 6], @m.get_headers([[1, 4, 6],
                                            [2, 5],
                                            [3]], true, false))

    assert_equal([1], @m.get_headers([[1],
                                      [2, 4],
                                      [3, 5, 6]], true, false))

    assert_equal(nil, @m.get_headers([[1, 2, 3],
                                      [4, 5, 6],
                                      [7, 8, 9]], false, true))

    assert_equal(nil, @m.get_headers([[1, 2, 3],
                                      [4, 5, 6],
                                      [7, 8, 9]], false, false))

    assert_equal([1, 2, 3], @m.get_headers([[1, 2, 3]], true, false))
  end

  test :get_series do
    n = nil

    assert_equal([[2, 3], [5, 6], [8, 9]], @m.get_series([[1, 2, 3],
                                                          [4, 5, 6],
                                                          [7, 8, 9]], true, true))

    assert_equal([[4, 6], [5], []], @m.get_series([[1, 4, 6],
                                                   [2, 5],
                                                   [3]], true, true))

    assert_equal([[], [4], [5, 6]], @m.get_series([[1],
                                                   [2, 4],
                                                   [3, 5, 6]], true, true))

    assert_equal([[4, 7], [5, 8], [6, 9]], @m.get_series([[1, 2, 3],
                                                          [4, 5, 6],
                                                          [7, 8, 9]], true, false))

    assert_equal([[2, 3], [5, nil]], @m.get_series([[1, 4, 6],
                                                    [2, 5],
                                                    [3]], true, false))

    assert_equal([[2, 3], [4, 5], [nil, 6]], @m.get_series([[1],
                                                            [2, 4],
                                                            [3, 5, 6]], true, false))

    assert_equal([[1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9]], @m.get_series([[1, 2, 3],
                                             [4, 5, 6],
                                             [7, 8, 9]], false, true))

    assert_equal([[1, 4, 6],
                  [2, 5],
                  [3]], @m.get_series([[1, 4, 6],
                                       [2, 5],
                                       [3]], false, true))

    assert_equal([[1],
                  [2, 4],
                  [3, 5, 6]], @m.get_series([[1],
                                             [2, 4],
                                             [3, 5, 6]], false, true))

    assert_equal([[1, 4, 7],
                  [2, 5, 8],
                  [3, 6, 9]], @m.get_series([[1, 2, 3],
                                             [4, 5, 6],
                                             [7, 8, 9]], false, false))

    assert_equal([[1, 2, 3],
                  [4, 5, n],
                  [6, n, n]], @m.get_series([[1, 4, 6],
                                             [2, 5],
                                             [3]], false, false))

    assert_equal([[1, 2, 3],
                  [n, 4, 5],
                  [n, n, 6]], @m.get_series([[1],
                                             [2, 4],
                                             [3, 5, 6]], false, false))

    assert_equal([[], [], []], @m.get_series([[1, 2, 3]], true, false))
  end
end
