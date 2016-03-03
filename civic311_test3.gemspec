# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'civic311_test3/version'

Gem::Specification.new do |spec|
  spec.name          = "civic311_test3"
  spec.version       = Civic311Test3::VERSION
  spec.authors       = ["pratik963"]
  spec.email         = ["pratik.spaceo@gmail.com"]
  spec.summary       = ["summary"]
  spec.description   = ["description"]
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "kaminari", "~> 0.16.3"
end
