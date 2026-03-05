require "bundler/setup"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", dir)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["universidade:js:build"])
end
Rake::Task["build"].enhance(["js:build"])
Rake::Task["release"].enhance(["js:build"])
