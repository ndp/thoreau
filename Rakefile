require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/testtask"

RSpec::Core::RakeTask.new(:rspec)


Rake::TestTask.new(:minitest) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["minitest/**/*_test.rb"]
end

desc 'Run RSpec and MiniTest'
task(:test => [:rspec, :minitest])

task :default => :test
