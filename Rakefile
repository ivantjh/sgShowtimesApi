require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require_relative 'server'
  end
end

desc 'Start scraper'
task :start_scraper do
  require_relative 'app/scraper/scraper'
  Scraper.start_scraper
end

desc 'Run maintenance module'
task :maintenance do
  require_relative 'app/maintenance'
  Maintenance.run
end

desc 'Run server in production'
task :run_production do
  sh "RACK_ENV='production' ruby server.rb"
end
