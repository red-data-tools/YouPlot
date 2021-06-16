# frozen_string_literal: true

require 'tempfile'
require_relative '../test_helper'

class YouPlotSimpleTest < Test::Unit::TestCase
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
    $stdin = File.open(File.expand_path('../fixtures/simple.tsv', __dir__), 'r')
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

  # Single command
  # The goal is to verify that the command works without any options.

  test :barplot do
    assert_raise(ArgumentError) do
      YouPlot::Command.new(['barplot']).run
    end
  end

  test :bar do
    assert_raise(ArgumentError) do
      YouPlot::Command.new(['bar']).run
    end
  end

  test :histogram do
    YouPlot::Command.new(['histogram']).run
    assert_equal fixture('simple-histogram.txt'), @stderr_file.read
  end

  test :hist do
    YouPlot::Command.new(['hist']).run
    assert_equal fixture('simple-histogram.txt'), @stderr_file.read
  end

  test :lineplot do
    YouPlot::Command.new(['lineplot']).run
    assert_equal fixture('simple-lineplot.txt'), @stderr_file.read
  end

  test :line do
    YouPlot::Command.new(['line']).run
    assert_equal fixture('simple-lineplot.txt'), @stderr_file.read
  end

  test :lineplots do
    assert_raise(YouPlot::Backends::UnicodePlot::Error) do
      YouPlot::Command.new(['lineplots']).run
    end
  end

  test :lines do
    assert_raise(YouPlot::Backends::UnicodePlot::Error) do
      YouPlot::Command.new(['lines']).run
    end
  end

  test :scatter do
    assert_raise(YouPlot::Backends::UnicodePlot::Error) do
      YouPlot::Command.new(['scatter']).run
    end
  end

  test :s do
    assert_raise(YouPlot::Backends::UnicodePlot::Error) do
      YouPlot::Command.new(['s']).run
    end
  end

  test :density do
    assert_raise(YouPlot::Backends::UnicodePlot::Error) do
      YouPlot::Command.new(['density']).run
    end
  end

  test :d do
    assert_raise(YouPlot::Backends::UnicodePlot::Error) do
      YouPlot::Command.new(['d']).run
    end
  end

  test :boxplot do
    YouPlot::Command.new(['boxplot']).run
    assert_equal fixture('simple-boxplot.txt'), @stderr_file.read
  end

  test :box do
    YouPlot::Command.new(['box']).run
    assert_equal fixture('simple-boxplot.txt'), @stderr_file.read
  end

  test :count do
    YouPlot::Command.new(['c']).run
    assert_equal fixture('simple-count.txt'), @stderr_file.read
  end

  test :c do
    YouPlot::Command.new(['count']).run
    assert_equal fixture('simple-count.txt'), @stderr_file.read
  end

  test :plot_output_stdout do
    YouPlot::Command.new(['line', '-o']).run
    assert_equal '', @stderr_file.read
    assert_equal fixture('simple-lineplot.txt'), @stdout_file.read
  end

  test :data_output_stdout do
    YouPlot::Command.new(['box', '-O']).run
    assert_equal fixture('simple-boxplot.txt'), @stderr_file.read
    assert_equal fixture('simple.tsv'), @stdout_file.read
  end

  test :line_transpose do
    $stdin = File.open(File.expand_path('../fixtures/simpleT.tsv', __dir__), 'r')
    YouPlot::Command.new(['line', '--transpose']).run
    assert_equal fixture('simple-lineplot.txt'), @stderr_file.read
  end

  test :line_T do
    $stdin = File.open(File.expand_path('../fixtures/simpleT.tsv', __dir__), 'r')
    YouPlot::Command.new(['line', '-T']).run
    assert_equal fixture('simple-lineplot.txt'), @stderr_file.read
  end

  test :line_xlabel do
    YouPlot::Command.new(['line', '--xlabel', 'X-LABEL']).run
    assert_equal fixture('simple-lineplot-xlabel.txt'), @stderr_file.read
  end

  test :line_ylabel do
    YouPlot::Command.new(['line', '--ylabel', 'Y-LABEL']).run
    assert_equal fixture('simple-lineplot-ylabel.txt'), @stderr_file.read
  end

  test :line_width do
    YouPlot::Command.new(['line', '--width', '17']).run
    assert_equal fixture('simple-lineplot-width-17.txt'), @stderr_file.read
  end

  test :line_w do
    YouPlot::Command.new(['line', '-w', '17']).run
    assert_equal fixture('simple-lineplot-width-17.txt'), @stderr_file.read
  end

  test :line_height do
    YouPlot::Command.new(['line', '--height', '17']).run
    assert_equal fixture('simple-lineplot-height-17.txt'), @stderr_file.read
  end

  test :line_h do
    YouPlot::Command.new(['line', '-h', '17']).run
    assert_equal fixture('simple-lineplot-height-17.txt'), @stderr_file.read
  end

  test :line_margin do
    YouPlot::Command.new(['line', '--margin', '17']).run
    assert_equal fixture('simple-lineplot-margin-17.txt'), @stderr_file.read
  end

  test :line_m do
    YouPlot::Command.new(['line', '-m', '17']).run
    assert_equal fixture('simple-lineplot-margin-17.txt'), @stderr_file.read
  end

  test :line_padding do
    YouPlot::Command.new(['line', '--padding', '17']).run
    assert_equal fixture('simple-lineplot-padding-17.txt'), @stderr_file.read
  end

  test :line_border_corners do
    YouPlot::Command.new(['line', '--border', 'corners']).run
    assert_equal fixture('simple-lineplot-border-corners.txt'), @stderr_file.read
  end

  test :line_b_corners do
    YouPlot::Command.new(['line', '-b', 'corners']).run
    assert_equal fixture('simple-lineplot-border-corners.txt'), @stderr_file.read
  end

  test :line_border_barplot do
    YouPlot::Command.new(['line', '--border', 'barplot']).run
    assert_equal fixture('simple-lineplot-border-barplot.txt'), @stderr_file.read
  end

  test :line_b_barplot do
    YouPlot::Command.new(['line', '-b', 'barplot']).run
    assert_equal fixture('simple-lineplot-border-barplot.txt'), @stderr_file.read
  end

  test :line_canvas_ascii do
    YouPlot::Command.new(['line', '--canvas', 'ascii']).run
    assert_equal fixture('simple-lineplot-canvas-ascii.txt'), @stderr_file.read
  end

  test :line_canvas_braille do
    YouPlot::Command.new(['line', '--canvas', 'braille']).run
    assert_equal fixture('simple-lineplot.txt'), @stderr_file.read
  end

  test :line_canvas_density do
    YouPlot::Command.new(['line', '--canvas', 'density']).run
    assert_equal fixture('simple-lineplot-canvas-density.txt'), @stderr_file.read
  end

  test :line_canvas_dot do
    YouPlot::Command.new(['line', '--canvas', 'dot']).run
    assert_equal fixture('simple-lineplot-canvas-dot.txt'), @stderr_file.read
  end

  # test :line_canvas_block do
  #   YouPlot::Command.new(['line', '--canvas', 'block']).run
  #   assert_equal fixture('simple-lineplot-canvas-dot.txt'), @stderr_file.read
  # end

  test :hist_symbol_atmark do
    YouPlot::Command.new(['hist', '--symbol', '@']).run
    assert_equal fixture('simple-histogram-symbol-@.txt'), @stderr_file.read
  end

  test :line_xlim do
    YouPlot::Command.new(['line', '--xlim', '-1,5']).run
    assert_equal fixture('simple-lineplot-xlim--1-5.txt'), @stderr_file.read
  end

  test :line_ylim do
    YouPlot::Command.new(['line', '--ylim', '-25,50']).run
    assert_equal fixture('simple-lineplot-ylim--25-50.txt'), @stderr_file.read
  end

  test :line_xlim_and_ylim do
    YouPlot::Command.new(['line', '--xlim', '-1,5', '--ylim', '-25,50']).run
    assert_equal fixture('simple-lineplot-xlim--1-5-ylim--25-50.txt'), @stderr_file.read
  end

  test :line_grid do
    YouPlot::Command.new(['line', '--grid']).run
    assert_equal fixture('simple-lineplot.txt'), @stderr_file.read
  end

  test :line_no_grid do
    YouPlot::Command.new(['line', '--no-grid']).run
    assert_equal fixture('simple-lineplot-no-grid.txt'), @stderr_file.read
  end
end
