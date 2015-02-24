# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'biola_wcms_components/version'

Gem::Specification.new do |spec|
  spec.name          = "biola_wcms_components"
  spec.version       = BiolaWcmsComponents::VERSION
  spec.authors       = ["Ryan Hall"]
  spec.email         = ["ryan.hall@biola.edu"]
  spec.description   = %q{this is a description}
  spec.summary       = %q{this is a summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "coffee-rails",         "~> 4.0"
  spec.add_dependency "sass-rails",           ">= 4.0"
  spec.add_dependency "slim",                 "~> 2.0"
  spec.add_development_dependency "bundler",  "~> 1.3"
  spec.add_development_dependency "rake"
end
