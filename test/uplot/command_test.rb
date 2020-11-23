# frozen_string_literal: true

require "tempfile"
require_relative '../test_helper'

class YouPlotCommandTest < Test::Unit::TestCase
  def startup
  end

  def setup
    @stdin  = $stdin.dup
    $stdin  = File.open(File.expand_path("../fixtures/iris.csv", __dir__), "r")
    @stderr = $stderr.dup
  end

  def cleanup
    $stdin  = @stdin
    $stderr = @stderr
  end

  def fixture(fname)
    File.read(File.expand_path("../fixtures/#{fname}", __dir__))
  end

  test :scatter do
    Tempfile.new do |tmp_file|
      $stderr = tmp_file
      YouPlot::Command.new(["scatter", "-H", "-d,", "-t", "IRIS"]).run
      assert_equal fixture('iris-scatter.txt'), tmp_file.read
    end
  end

  test :barplot do
    Tempfile.new do |tmp_file|
      $stderr = tmp_file
      YouPlot::Command.new(["barplot", "-H", "-d,", "-t", "IRIS"]).run
      assert_equal fixture('iris-bar.txt'), tmp_file.read
    end
  end

end
