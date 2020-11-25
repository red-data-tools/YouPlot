# frozen_string_literal: true

require 'tempfile'
require_relative '../test_helper'

class YouPlotCommandTest < Test::Unit::TestCase
  class << self
    def startup
      @stdin  = $stdin.dup
      @stderr = $stderr.dup
    end

    def shutdown
      $stdin  = @stdin
      $stderr = @stderr
    end
  end

  def setup
    $stdin = File.open(File.expand_path('../fixtures/iris.csv', __dir__), 'r')
    @tmp_file = Tempfile.new
    $stderr = @tmp_file
  end

  def teardown
    @tmp_file.close
  end

  def fixture(fname)
    File.read(File.expand_path("../fixtures/#{fname}", __dir__))
  end

  test :bar do
    YouPlot::Command.new(['bar', '-H', '-d,', '-t', 'IRIS-BARPLOT']).run
    assert_equal fixture('iris-barplot.txt'), @tmp_file.read
  end

  test :barplot do
    YouPlot::Command.new(['barplot', '-H', '-d,', '-t', 'IRIS-BARPLOT']).run
    assert_equal fixture('iris-barplot.txt'), @tmp_file.read
  end

  test :hist do
    YouPlot::Command.new(['hist', '-H', '-d,', '-t', 'IRIS-HISTOGRAM']).run
    assert_equal fixture('iris-histogram.txt'), @tmp_file.read
  end

  test :histogram do
    YouPlot::Command.new(['histogram', '-H', '-d,', '-t', 'IRIS-HISTOGRAM']).run
    assert_equal fixture('iris-histogram.txt'), @tmp_file.read
  end

  test :line do
    YouPlot::Command.new(['line', '-H', '-d,', '-t', 'IRIS-LINEPLOT']).run
    assert_equal fixture('iris-lineplot.txt'), @tmp_file.read
  end

  test :lineplot do
    YouPlot::Command.new(['lineplot', '-H', '-d,', '-t', 'IRIS-LINEPLOT']).run
    assert_equal fixture('iris-lineplot.txt'), @tmp_file.read
  end

  test :lines do
    YouPlot::Command.new(['lines', '-H', '-d,', '-t', 'IRIS-LINEPLOTS']).run
    assert_equal fixture('iris-lineplots.txt'), @tmp_file.read
  end

  test :lineplots do
    YouPlot::Command.new(['lineplots', '-H', '-d,', '-t', 'IRIS-LINEPLOTS']).run
    assert_equal fixture('iris-lineplots.txt'), @tmp_file.read
  end

  test :s do
    YouPlot::Command.new(['s', '-H', '-d,', '-t', 'IRIS-SCATTER']).run
    assert_equal fixture('iris-scatter.txt'), @tmp_file.read
  end

  test :scatter do
    YouPlot::Command.new(['scatter', '-H', '-d,', '-t', 'IRIS-SCATTER']).run
    assert_equal fixture('iris-scatter.txt'), @tmp_file.read
  end

  test :d do
    YouPlot::Command.new(['d', '-H', '-d,', '-t', 'IRIS-DENSITY']).run
    assert_equal fixture('iris-density.txt'), @tmp_file.read
  end

  test :density do
    YouPlot::Command.new(['density', '-H', '-d,', '-t', 'IRIS-DENSITY']).run
    assert_equal fixture('iris-density.txt'), @tmp_file.read
  end

  test :box do
    YouPlot::Command.new(['box', '-H', '-d,', '-t', 'IRIS-BOXPLOT']).run
    assert_equal fixture('iris-boxplot.txt'), @tmp_file.read
  end

  test :boxplot do
    YouPlot::Command.new(['boxplot', '-H', '-d,', '-t', 'IRIS-BOXPLOT']).run
    assert_equal fixture('iris-boxplot.txt'), @tmp_file.read
  end
end
