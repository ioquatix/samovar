require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Load all rake tasks:
import(*Dir.glob('tasks/**/*.rake'))

RSpec::Core::RakeTask.new(:test)

task :default => :test
