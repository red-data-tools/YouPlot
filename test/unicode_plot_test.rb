# frozen_string_literal: true

require_relative 'test_helper'
require 'unicode_plot'

# Check the UnicodePlot constants that YouPlot depends on.
# Prepare for UnicodePlot version upgrades.
class UnicodePlotTest < Test::Unit::TestCase
  test 'VERSION' do
    assert UnicodePlot::VERSION
  end

  test 'BORDER_MAP' do
    assert_instance_of Hash, UnicodePlot::BORDER_MAP
  end

  test 'PREDEFINED_TRANSFORM_FUNCTIONS' do
    assert_instance_of Hash, UnicodePlot::ValueTransformer::PREDEFINED_TRANSFORM_FUNCTIONS
  end
end
