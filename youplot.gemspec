# frozen_string_literal: true

require_relative 'lib/youplot/version'

Gem::Specification.new do |spec|
  spec.name          = 'youplot'
  spec.version       = YouPlot::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'A command line tool for Unicode Plotting'
  spec.description   = 'A command line tool for Unicode Plotting'
  spec.homepage      = 'https://github.com/kojix2/youplot'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.files         = Dir['*.{md,txt}', '{lib,exe}/**/*']
  spec.bindir        = 'exe'
  spec.executables   = %w[uplot youplot]
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'unicode_plot'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'test-unit'
end
