# frozen_string_literal: true

require_relative 'youplot/version'
require_relative 'youplot/dsv'
require_relative 'youplot/parameters'
require_relative 'youplot/command'

module YouPlot
  class << self
    attr_accessor :run_as_executable

    def run_as_executable?
      @run_as_executable
    end
  end
  @run_as_executable = false
end
