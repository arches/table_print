# -*- encoding: utf-8 -*-
require File.expand_path('../lib/table_print/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name                = "table_print"

  gem.authors             = ["Chris Doyle"]
  gem.email               = ["archslide@gmail.com"]
  gem.email               = "archslide@gmail.com"

  gem.description         = "TablePrint formats an object or array of objects into columns for easy reading. To do this, it assumes the objects in your array all respond to the same methods (vs pretty_print or awesome_print, who can't create columns because your objects could be entirely different)."
  gem.summary             = "Turn objects into nicely formatted columns for easy reading"
  gem.homepage            = "http://tableprintgem.com"
  gem.version             = TablePrint::VERSION

  gem.files               = `git ls-files`.split($\)
  gem.test_files          = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths       = ["lib"]

  gem.add_development_dependency 'cat', '~> 0.2.1'
  gem.add_development_dependency 'cucumber', '~> 1.2.1'
  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'rake', '~> 0.9.2'
end
