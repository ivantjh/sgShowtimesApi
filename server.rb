require 'sinatra/base'
require 'sinatra/activerecord'
require 'multi_json'
MultiJson.use :yajl

require_relative 'app/scraper/scraper'

# nodoc
class SgShowtimesApi < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :development do
    set :database, adapter: 'sqlite3', database: 'db.sqlite3'
    set :show_exceptions, :after_handler

    # Scraper.find_showtimes
  end

  before do
    content_type :json
  end

  get '/movies' do
    @movies = Movie.includes(:genres).all
    @movies.map { |movie| movie.to_builder.target! }
  end

  get '/movie/:id' do
    @movie = Movie.includes(:showtimes, :cinemas).find_by(id: params['id'])

    if @movie
      @movie.showtimes_json.target!
      # @movie.showtimes_json
    else
      halt 404, '404 Movie resource not found'
    end
  end

  # provide endpoints for today, tmrw, dayafter

  error Sinatra::NotFound do
    content_type :text
    status 404
    '404 This is not the endpoint you are looking for.'
  end

  run! if app_file == $PROGRAM_NAME
end
