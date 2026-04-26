# frozen_string_literal: true

require 'tempfile'
require 'tmpdir'
require 'stringio'
require_relative '../test_helper'

class YouPlotParserTest < Test::Unit::TestCase
  def setup
    # find_config_file sets MYYOUPLOTRC as a side effect; isolate tests.
    @original_myyouplotrc = ENV['MYYOUPLOTRC']
    ENV.delete('MYYOUPLOTRC')
  end

  def teardown
    # Restore to avoid leaking into other tests.
    if @original_myyouplotrc.nil?
      ENV.delete('MYYOUPLOTRC')
    else
      ENV['MYYOUPLOTRC'] = @original_myyouplotrc
    end
  end

  def with_temp_config(content)
    Tempfile.create(['youplot', '.yml']) do |file|
      file.write(content)
      file.flush
      yield file.path
    end
  end

  def capture_stdout
    original_stdout = $stdout
    stdout = StringIO.new
    $stdout = stdout
    yield
    stdout.string
  ensure
    $stdout = original_stdout
  end

  test :cli_overrides_config_file_values do
    with_temp_config(<<~YAML) do |config_path|
      width: 80
      labels: true
      delimiter: ","
      fmt: yx
    YAML
      parser = YouPlot::Parser.new
      parser.parse_options(['line', '--config', config_path, '--no-labels', '-w', '40', '--fmt', 'xy'])

      assert_equal 40, parser.params.width
      assert_equal false, parser.params.labels
      assert_equal ',', parser.options.delimiter
      assert_equal 'xy', parser.options.fmt
    end
  end

  test :explicit_config_file_overrides_default_search do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        # Create a config file in the current directory
        File.write('.youplot.yml', "width: 10\n")

        # Explicitly specify a different config file
        with_temp_config("width: 80\n") do |config_path|
          parser = YouPlot::Parser.new
          parser.parse_options(['line', "--config=#{config_path}"])

          assert_equal 80, parser.params.width
        end
      end
    end
  end

  test :show_config_info_uses_explicit_config_file do
    with_temp_config("width: 80\n") do |config_path|
      parser = YouPlot::Parser.new
      parser.parse_options(['line', "--config=#{config_path}"])

      output = capture_stdout do
        parser.show_config_info
      end

      assert_include output, "config file : #{config_path}"
      assert_include output, '"width" => 80'
    end
  end
end
