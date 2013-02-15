# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blinkenstein/version'

Gem::Specification.new do |gem|
  gem.name          = "blinkenstein"
  gem.version       = Blinkenstein::VERSION
  gem.authors       = ["Michael Schmidt"]
  gem.email         = ["michael.j.schmidt@gmail.com"]
  gem.description   = %q{Blink(1) Monitoring Thinggy}
  gem.summary       = %q{Currently monitors Eve Online's skill queue and messes with Blink(1)'}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('celluloid')
  gem.add_dependency('rb-blink1')
  gem.add_dependency('httparty')
  gem.add_dependency('nokogiri')
end
