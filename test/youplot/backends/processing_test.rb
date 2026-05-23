# frozen_string_literal: true

require_relative '../../test_helper'

class ProcessingTest < Test::Unit::TestCase
  test :count_values do
    @m = YouPlot::Backends::Processing
    assert_equal([%i[a b c], [3, 2, 1]], @m.count_values(%i[a a a b b c]))
    assert_equal([%i[c b a], [3, 2, 1]], @m.count_values(%i[a b b c c c]))
  end

  test :count_values_natural_sort_integer_labels do
    @m = YouPlot::Backends::Processing
    assert_equal([%w[19 187 1765], [1, 1, 1]], @m.count_values(%w[1765 187 19]))
  end

  test :count_values_natural_sort_alnum_labels do
    @m = YouPlot::Backends::Processing
    assert_equal([%w[a1 a2 a10], [1, 1, 1]], @m.count_values(%w[a10 a2 a1]))
  end

  test :count_values_natural_sort_negative_numeric_labels do
    @m = YouPlot::Backends::Processing
    assert_equal([%w[-20 -10 10], [1, 1, 1]], @m.count_values(%w[-10 10 -20]))
  end

  test :count_values_natural_sort_chr_labels do
    @m = YouPlot::Backends::Processing
    assert_equal(
      [%w[chr1 chr2 chr10 chr11 chr12], [1, 1, 1, 1, 1]],
      @m.count_values(%w[chr12 chr1 chr11 chr10 chr2])
    )
  end

  test :count_values_natural_sort_text_only_labels do
    @m = YouPlot::Backends::Processing
    assert_equal([%w[chrM chrX chrY], [1, 1, 1]], @m.count_values(%w[chrY chrX chrM]))
  end

  test :count_values_natural_sort_leading_zeros do
    @m = YouPlot::Backends::Processing
    assert_equal([%w[01 1 2], [1, 1, 1]], @m.count_values(%w[2 1 01]))
  end

  test :count_values_natural_sort_mixed_numeric_and_text do
    @m = YouPlot::Backends::Processing
    assert_equal([%w[2 10 abc], [1, 1, 1]], @m.count_values(%w[abc 10 2]))
  end

  test :count_values_natural_sort_numeric_and_mixed_labels do
    @m = YouPlot::Backends::Processing
    assert_equal([%w[2 2a 10], [1, 1, 1]], @m.count_values(%w[10 2a 2]))
  end

  test :count_values_natural_sort_ipv4_labels do
    @m = YouPlot::Backends::Processing
    assert_equal(
      [%w[192.168.0.2 192.168.0.10 192.168.1.1], [1, 1, 1]],
      @m.count_values(%w[192.168.1.1 192.168.0.10 192.168.0.2])
    )
  end

  test :count_values_natural_sort_version_labels do
    @m = YouPlot::Backends::Processing
    assert_equal(
      [%w[1.2.3 1.2.10 1.10.0], [1, 1, 1]],
      @m.count_values(%w[1.10.0 1.2.10 1.2.3])
    )
  end

  test :count_values_mixed_counts_with_ties do
    @m = YouPlot::Backends::Processing
    # "a" appears 3 times (top), then "chr1" and "chr10" tie at 1 each
    assert_equal(
      [%w[a chr1 chr10], [3, 1, 1]],
      @m.count_values(%w[a a a chr10 chr1])
    )
  end

  test :count_values_reverse_preserves_semantics do
    @m = YouPlot::Backends::Processing
    assert_equal([%w[1765 187 19], [1, 1, 1]], @m.count_values(%w[1765 187 19], reverse: true))
  end

  test :count_values_non_tally do
    @m = YouPlot::Backends::Processing
    assert_equal([%i[a b c], [3, 2, 1]], @m.count_values(%i[a a a b b c], tally: false))
    assert_equal([%i[c b a], [3, 2, 1]], @m.count_values(%i[a b b c c c], tally: false))
  end
end
