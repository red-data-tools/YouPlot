# frozen_string_literal: true

require 'tempfile'
require_relative '../test_helper'

class YouPlotIRISTest < Test::Unit::TestCase
  class << self
    def startup
      @stdin  = $stdin.dup
      @stdout = $stdout.dup
      @stderr = $stderr.dup
    end

    def shutdown
      $stdin  = @stdin
      $stdout = @stdout
      $stderr = @stderr
    end
  end

  def setup
    $stdin = File.open(File.expand_path('../fixtures/iris.csv', __dir__), 'r')
    @stderr_file = Tempfile.new
    @stdout_file = Tempfile.new
    $stderr = @stderr_file
    $stdout = @stdout_file
  end

  def teardown
    @stderr_file.close
    @stdout_file.close
  end

  def fixture(fname)
    File.read(File.expand_path("../fixtures/#{fname}", __dir__))
  end

  test :barplot do
    YouPlot::Command.new(['barplot', '-H', '-d,', '-t', 'IRIS-BARPLOT']).run
    assert_equal fixture('iris-barplot.txt'), @stderr_file.read
  end

  # barplot doesn't make sense, but just to make sure it works.

  test :bar do
    YouPlot::Command.new(['bar', '-H', '-d,', '-t', 'IRIS-BARPLOT']).run
    assert_equal fixture('iris-barplot.txt'), @stderr_file.read
  end

  test :histogram do
    YouPlot::Command.new(['histogram', '-H', '-d,', '-t', 'IRIS-HISTOGRAM']).run
    assert_equal fixture('iris-histogram.txt'), @stderr_file.read
  end

  test :hist do
    YouPlot::Command.new(['hist', '-H', '-d,', '-t', 'IRIS-HISTOGRAM']).run
    assert_equal fixture('iris-histogram.txt'), @stderr_file.read
  end

  # Yeah, lineplot/lineplots don't make sense too.

  test :lineplot do
    YouPlot::Command.new(['lineplot', '-H', '-d,', '-t', 'IRIS-LINEPLOT']).run
    assert_equal fixture('iris-lineplot.txt'), @stderr_file.read
  end

  test :line do
    YouPlot::Command.new(['line', '-H', '-d,', '-t', 'IRIS-LINEPLOT']).run
    assert_equal fixture('iris-lineplot.txt'), @stderr_file.read
  end

  # l is an undocumented alias of lineplot.
  test :l do
    YouPlot::Command.new(['l', '-H', '-d,', '-t', 'IRIS-LINEPLOT']).run
    assert_equal fixture('iris-lineplot.txt'), @stderr_file.read
  end

  test :lineplots do
    YouPlot::Command.new(['lineplots', '-H', '-d,', '-t', 'IRIS-LINEPLOTS']).run
    assert_equal fixture('iris-lineplots.txt'), @stderr_file.read
  end

  test :lines do
    YouPlot::Command.new(['lines', '-H', '-d,', '-t', 'IRIS-LINEPLOTS']).run
    assert_equal fixture('iris-lineplots.txt'), @stderr_file.read
  end

  # ls is an undocumented alias of lineplots.
  test :ls do
    YouPlot::Command.new(['lines', '-H', '-d,', '-t', 'IRIS-LINEPLOTS']).run
    assert_equal fixture('iris-lineplots.txt'), @stderr_file.read
  end

  test :scatter do
    YouPlot::Command.new(['scatter', '-H', '-d,', '-t', 'IRIS-SCATTER']).run
    assert_equal fixture('iris-scatter.txt'), @stderr_file.read
  end

  test :s do
    YouPlot::Command.new(['s', '-H', '-d,', '-t', 'IRIS-SCATTER']).run
    assert_equal fixture('iris-scatter.txt'), @stderr_file.read
  end

  test :density do
    YouPlot::Command.new(['density', '-H', '-d,', '-t', 'IRIS-DENSITY']).run
    assert_equal fixture('iris-density.txt'), @stderr_file.read
  end

  test :d do
    YouPlot::Command.new(['d', '-H', '-d,', '-t', 'IRIS-DENSITY']).run
    assert_equal fixture('iris-density.txt'), @stderr_file.read
  end

  test :boxplot do
    YouPlot::Command.new(['boxplot', '-H', '-d,', '-t', 'IRIS-BOXPLOT']).run
    assert_equal fixture('iris-boxplot.txt'), @stderr_file.read
  end

  test :box do
    YouPlot::Command.new(['box', '-H', '-d,', '-t', 'IRIS-BOXPLOT']).run
    assert_equal fixture('iris-boxplot.txt'), @stderr_file.read
  end

  # Yeah, lineplot/lineplots don't make sense too.
  # Just checking the behavior.

  test :c do
    YouPlot::Command.new(['count', '-H', '-d,']).run
    assert_equal fixture('iris-count.txt'), @stderr_file.read
  end

  test :count do
    YouPlot::Command.new(['c', '-H', '-d,']).run
    assert_equal fixture('iris-count.txt'), @stderr_file.read
  end

  # Output options.

  test :plot_output_stdout do
    YouPlot::Command.new(['bar', '-o', '-H', '-d,', '-t', 'IRIS-BARPLOT']).run
    assert_equal '', @stderr_file.read
    assert_equal fixture('iris-barplot.txt'), @stdout_file.read
  end

  test :data_output_stdout do
    YouPlot::Command.new(['bar', '-O', '-H', '-d,', '-t', 'IRIS-BARPLOT']).run
    assert_equal fixture('iris-barplot.txt'), @stderr_file.read
    assert_equal fixture('iris.csv'), @stdout_file.read
  end

  %i[colors color colours colour].each do |cmd_name|
    test cmd_name do
      YouPlot::Command.new([cmd_name.to_s]).run
      assert_equal fixture('colors.txt'), @stderr_file.read
      assert_equal '', @stdout_file.read
    end
  end

  test :colors_output_stdout do
    YouPlot::Command.new(['colors', '-o']).run
    assert_equal '', @stderr_file.read
    assert_equal fixture('colors.txt'), @stdout_file.read
  end

  test :unrecognized_command do
    assert_raise(YouPlot::Parser::Error) do
      YouPlot::Command.new(['abracadabra', '--hadley', '--wickham']).run
    end
    assert_equal '', @stderr_file.read
    assert_equal '', @stdout_file.read
  end

  test :encoding do
    $stdin = File.open(File.expand_path('../fixtures/iris_utf16.csv', __dir__), 'r')
    YouPlot::Command.new(['s', '--encoding', 'UTF-16', '-H', '-d,', '-t', 'IRIS-SCATTER']).run
    assert_equal fixture('iris-scatter.txt'), @stderr_file.read
  end
end
