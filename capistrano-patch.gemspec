# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "capistrano/patch/version"

Gem::Specification.new do |s|
  s.name        = "capistrano-patch"
  s.version     = Capistrano::Patch::VERSION
  s.authors     = ["Andriy Yanko"]
  s.email       = ["andriy.yanko@gmail.com"]
  s.homepage    = "https://github.com/railsware/capistrano-patch"
  s.summary     = %q{Capistrano patch recipes}

  s.rubyforge_project = "capistrano-patch"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "capistrano", ">=2.5.5"
end
