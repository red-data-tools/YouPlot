# frozen_string_literal: true

require_relative 'youplot/version'
require_relative 'youplot/dsv'
require_relative 'youplot/parameters'
require_relative 'youplot/command'

module YouPlot
  # @run_as_executable = true / false
  # YouPlot behaves slightly differently when run as a command line tool
  # and when run as a script (e.g. for testing). In the event of an error,
  # when run as a command line tool, YouPlot will display a short error message
  # and exit abnormally. When run as a script, it will just raise an error.
  @run_as_executable = false
  class << self
    attr_accessor :run_as_executable

    def run_as_executable?
      @run_as_executable
    end
  end
end
