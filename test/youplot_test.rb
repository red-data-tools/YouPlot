# frozen_string_literal: true

require_relative 'test_helper'

class YouPlotTest < Test::Unit::TestCase
  def teardown
    YouPlot.run_as_executable = false
  end

  test :it_has_a_version_number do
    assert_kind_of String, ::YouPlot::VERSION
  end

  test :run_as_executable do
    assert_equal false, YouPlot.run_as_executable
    assert_equal false, YouPlot.run_as_executable?
    YouPlot.run_as_executable = true
    assert_equal true, YouPlot.run_as_executable
    assert_equal true, YouPlot.run_as_executable?
  end
end
