# frozen_string_literal: true

require 'unicode_plot'
require 'youplot/version'
require 'youplot/dsv'
require 'youplot/parameters'
require 'youplot/command'

module YouPlot
  class << self
    attr_accessor :run_as_executable

    def run_as_executable?
      @run_as_executable
    end
  end
  @run_as_executable = false
end
