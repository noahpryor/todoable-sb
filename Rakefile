require "bundler/gem_tasks"
task :default => :spec

task :spec do
  exec "rspec spec -f d"
end

task :console do
  exec "irb -r todoable -I ./lib"
end


task :coverage do
  exec "bundle exec coveralls push"
end
