# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apiary/version"

Gem::Specification.new do |s|
  s.name        = "apiary"
  s.version     = Apiary::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Hull"]
  s.email       = ["joshbuddy@gmail.com"]
  s.homepage    = "https://github.com/joshbuddy/apiary"
  s.summary     = %q{Convert your existing class into an EM-based API}
  s.description = %q{Convert your existing class into an EM-based API.}

  s.rubyforge_project = "apiary"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'callsite'
  s.add_dependency 'method-args'
  s.add_dependency 'thin'
  s.add_dependency 'http_router'
  s.add_dependency 'rack'
  s.add_dependency 'thin_async'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'em-http-request'
  s.add_development_dependency 'minitest', '~> 2.0.0'
end
