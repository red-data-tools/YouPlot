# frozen_string_literal: true

require 'stringio'
require_relative '../test_helper'

class YouPlotProgressiveTest < Test::Unit::TestCase
  def build_options(overrides = {})
    out = StringIO.new
    defaults = YouPlot::Options::DEFAULTS.merge(output: out, pass: false)
    options_hash = defaults.merge(overrides)
    YouPlot::Options.new(*YouPlot::Options.members.map { |k| options_hash[k] })
  end

  def build_data_with_progressive(command, lines)
    data = nil
    lines.each do |line|
      row = command.send(:parse_progressive_row, line)
      next if row.nil?

      data = command.send(:progressive_update_data, row)
    end
    data
  end

  def suppress_stderr
    stderr = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = stderr
  end

  test 'progressive incremental parsing without headers matches DSV.parse' do
    command = YouPlot::Command.new([])
    command.options = build_options(delimiter: "\t", headers: false, transpose: false)

    lines = %W[1\t2\n 3\n \n]
    actual = build_data_with_progressive(command, lines)
    expected = YouPlot::DSV.parse(lines.join, "\t", false, false)

    assert_equal expected.headers, actual.headers
    assert_equal expected.series, actual.series
    assert_nil command.instance_variable_get(:@raw_data)
  end

  test 'progressive incremental parsing with headers waits for first data row' do
    command = YouPlot::Command.new([])
    command.options = build_options(delimiter: "\t", headers: true, transpose: false)

    header_row = command.send(:parse_progressive_row, "h1\th2\n")
    first = command.send(:progressive_update_data, header_row)
    assert_nil first

    data_row = command.send(:parse_progressive_row, "1\t2\n")
    actual = command.send(:progressive_update_data, data_row)
    expected = YouPlot::DSV.parse("h1\th2\n1\t2\n", "\t", true, false)

    assert_equal expected.headers, actual.headers
    assert_equal expected.series, actual.series
  end

  test 'progressive incremental parsing with headers and transpose matches DSV.parse' do
    command = YouPlot::Command.new([])
    command.options = build_options(delimiter: "\t", headers: true, transpose: true)

    lines = %W[h1\t1\t2\n h2\t3\t4\n]
    actual = build_data_with_progressive(command, lines)
    expected = YouPlot::DSV.parse(lines.join, "\t", true, true)

    assert_equal expected.headers, actual.headers
    assert_equal expected.series, actual.series
  end

  test 'progressive with headers returns nil when headers are fewer than series' do
    command = YouPlot::Command.new([])
    command.options = build_options(delimiter: "\t", headers: true, transpose: false)

    lines = %W[h1\n 1\t2\n]
    actual = nil
    expected = nil
    suppress_stderr do
      actual = build_data_with_progressive(command, lines)
      expected = YouPlot::DSV.parse(lines.join, "\t", true, false)
    end

    assert_nil expected
    assert_nil actual
  end

  test 'progressive with headers returns nil when headers are greater than series' do
    command = YouPlot::Command.new([])
    command.options = build_options(delimiter: "\t", headers: true, transpose: false)

    lines = %W[h1\th2\n 1\n]
    actual = nil
    expected = nil
    suppress_stderr do
      actual = build_data_with_progressive(command, lines)
      expected = YouPlot::DSV.parse(lines.join, "\t", true, false)
    end

    assert_nil expected
    assert_nil actual
  end
end
