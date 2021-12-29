# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nacelle/version'

Gem::Specification.new do |spec|
  spec.name          = "nacelle"
  spec.version       = Nacelle::VERSION
  spec.authors       = ["Micah Geisel"]
  spec.email         = ["micah@botandrose.com"]

  spec.summary       = "Embed cells in the markup of your CMS."
  spec.description   = "Embed cells in the markup of your CMS."
  spec.homepage      = "https://github.com/botandrose/nacelle"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "byebug"

  spec.add_dependency "rails"
  spec.add_dependency "cells", "~>3.0"
end
