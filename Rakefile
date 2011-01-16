require 'rubygems'
require 'bundler'

desc "Run tests"
task :test do
  $: << 'lib'
  require 'apiary'
  require 'test/helper'
  Dir['test/**/test_*.rb'].each { |test| require test }
end

require 'rake/rdoctask'
desc "Generate documentation"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'rdoc'
end

#Bundler::GemHelper.install_tasks
