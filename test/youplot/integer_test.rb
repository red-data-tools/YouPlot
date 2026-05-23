# frozen_string_literal: true

require 'tempfile'
require_relative '../test_helper'

class YouPlotIntegerTest < Test::Unit::TestCase
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

  # Issue #44: When all values are integers, display without decimal points
  test :barplot_integer_values do
    $stdin = File.open(File.expand_path('../fixtures/integer.tsv', __dir__), 'r')
    YouPlot::Command.new(['bar']).run
    assert_equal fixture('integer-barplot.txt'), @stderr_file.read
  end

  test :barplot_float_values do
    $stdin = File.open(File.expand_path('../fixtures/integer-like-float.tsv', __dir__), 'r')
    YouPlot::Command.new(['bar']).run
    assert_equal fixture('integer-like-float-barplot.txt'), @stderr_file.read
  end
end
