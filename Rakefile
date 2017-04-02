require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require_relative 'server'
  end
end

namespace :scraper do
  task :start do
    require_relative 'app/scraper/scraper'
    Scraper.start_scraper
  end
end
