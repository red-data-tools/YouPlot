# frozen_string_literal: true

require "tempfile"
require_relative '../test_helper'

class YouPlotCommandTest < Test::Unit::TestCase
  def setup
    @ta = "ta"
    @stdin = $stdin.dup
    @stderr = $stderr.dup
  end

  test :scatter do
    $stdin  = File.open(File.expand_path("../fixtures/iris.csv", __dir__), "r")
    Tempfile.new("iris-scatter") do |tmp_file|
      $stderr = tmp_file
      YouPlot::Command.new(["scatter", "-H", "-d,", "-t", "IRIS"]).run
      assert_equal File.read(File.expand_path("../fixtures/iris-scatter.txt", __dir__)), tmp_file.read
    end
    $stdin = @stdin
    $stderr = @stderr
  end
end
