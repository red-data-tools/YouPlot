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
  end

  def fixture(fname)
    File.read(File.expand_path("../fixtures/#{fname}", __dir__))
  end

  test :bar do
    assert_raise(ArgumentError) do
      YouPlot::Command.new(['bar']).run
    end
  end

  test :barplot do
    assert_raise(ArgumentError) do
      YouPlot::Command.new(['barplot']).run
    end
  end

  test :hist do
    YouPlot::Command.new(['hist']).run
    assert_equal fixture('simple-histogram.txt'), @stderr_file.read
  end

  test :histogram do
    YouPlot::Command.new(['histogram']).run
    assert_equal fixture('simple-histogram.txt'), @stderr_file.read
  end

  test :line do
    YouPlot::Command.new(['line']).run
    assert_equal fixture('simple-lineplot.txt'), @stderr_file.read
  end

  test :lineplot do
    YouPlot::Command.new(['lineplot']).run
    assert_equal fixture('simple-lineplot.txt'), @stderr_file.read
  end

  test :lines do
    assert_raise(YouPlot::Backends::UnicodePlotBackend::Error) do
      YouPlot::Command.new(['lines']).run
    end
  end

  test :lineplots do
    assert_raise(YouPlot::Backends::UnicodePlotBackend::Error) do
      YouPlot::Command.new(['lineplots']).run
    end
  end

  test :s do
    assert_raise(YouPlot::Backends::UnicodePlotBackend::Error) do
      YouPlot::Command.new(['s']).run
    end
  end

  test :scatter do
    assert_raise(YouPlot::Backends::UnicodePlotBackend::Error) do
      YouPlot::Command.new(['scatter']).run
    end
  end

  test :d do
    assert_raise(YouPlot::Backends::UnicodePlotBackend::Error) do
      YouPlot::Command.new(['d']).run
    end
  end

  test :density do
    assert_raise(YouPlot::Backends::UnicodePlotBackend::Error) do
      YouPlot::Command.new(['density']).run
    end
  end

  test :box do
    YouPlot::Command.new(['box']).run
    assert_equal fixture('simple-boxplot.txt'), @stderr_file.read
  end

  test :boxplot do
    YouPlot::Command.new(['boxplot']).run
    assert_equal fixture('simple-boxplot.txt'), @stderr_file.read
  end

  # test :c do
  #   omit
  #   YouPlot::Command.new(['count', '-H', '-d,']).run
  #   assert_equal fixture('iris-count.txt'), @stderr_file.read
  # end

  # test :count do
  #   omit
  #   YouPlot::Command.new(['c', '-H', '-d,']).run
  #   assert_equal fixture('iris-count.txt'), @stderr_file.read
  # end

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
end
