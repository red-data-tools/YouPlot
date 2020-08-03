require_relative 'lib/uplot/version'

Gem::Specification.new do |spec|
  spec.name          = 'u-plot'
  spec.version       = Uplot::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'Create Ascii charts on your terminal.'
  spec.description   = <<~MSG
    Create ASCII charts on the terminal with data from standard streams in the 
    pipeline. 
  MSG
  spec.homepage      = 'https://github.com/kojix2/uplot'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.files         = Dir['*.{md,txt}', '{lib,exe}/**/*']
  spec.bindir        = 'exe'
  spec.executables   = ['uplot']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'unicode_plot'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'test-unit'
end
