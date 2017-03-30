require 'sinatra/base'
require 'sinatra/activerecord'

require_relative 'app/scraper/scraper'

# nodoc
class SgShowtimesApi < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :development do
    set :database, adapter: 'sqlite3', database: 'db.sqlite3'

    # Scraper.find_showtimes
  end

  get '/movies' do
    content_type :json
    @movies = Movie.all
    # @movies = Movie.includes(:genre).find()

    @movies.to_json
  end

  not_found do
    status 404
    '404 This is not the endpoint you are looking for.'
  end

  run! if app_file == $PROGRAM_NAME
end
