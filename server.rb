require 'sinatra'
require 'sinatra/activerecord'

require './app/scraper/scraper'

configure do
  set :database, { adapter: "sqlite3", database: "db.sqlite3"}

  Scrapper.find_showtimes
end

get '/' do
  'Hello guys!'
end
