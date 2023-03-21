# -*- encoding: utf-8 -*-
require File.expand_path('../lib/table_print/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name                = "table_print"

  gem.authors             = ["Chris Doyle"]
  gem.email               = ["chris@arches.io"]
  gem.email               = "chris@arches.io"

  gem.description         = "TablePrint turns objects into nicely formatted columns for easy reading. Works great in rails console, works on pure ruby objects, autodetects columns, lets you traverse ActiveRecord associations. Simple, powerful."
  gem.summary             = "Turn objects into nicely formatted columns for easy reading"
  gem.homepage            = "http://tableprintgem.com"
  gem.version             = TablePrint::VERSION
  gem.license             = 'MIT'

  gem.files               = `git ls-files`.split($\)
  gem.test_files          = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths       = ["lib"]

  gem.add_development_dependency 'cat', '~> 0.2.1'
  gem.add_development_dependency 'cucumber', '>= 7.1.0'
  gem.add_development_dependency 'rspec', '~> 3.12.0'
  gem.add_development_dependency 'rake', '~> 13.0'
end
