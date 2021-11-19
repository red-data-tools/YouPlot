# frozen_string_literal: true

require_relative 'lib/youplot/version'

Gem::Specification.new do |spec|
  spec.name          = 'youplot'
  spec.version       = YouPlot::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'A command line tool for Unicode Plotting'
  spec.description   = 'A command line tool for Unicode Plotting'
  spec.homepage      = 'https://github.com/red-data-tools/YouPlot'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.files         = Dir['*.{md,txt}', '{lib,exe}/**/*']
  spec.bindir        = 'exe'
  spec.executables   = %w[uplot youplot]
  spec.require_paths = ['lib']

  spec.add_dependency 'unicode_plot', '>= 0.0.5'
end
