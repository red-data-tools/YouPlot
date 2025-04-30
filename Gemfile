# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in youplot.gemspec
gemspec

group :development do
  if RUBY_VERSION >= '3.0'
    gem 'steep', require: false
    gem 'typeprof'
  end
end

group :test do
  gem 'rake'
  gem 'simplecov'
  gem 'test-unit'
end
