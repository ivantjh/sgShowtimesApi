require 'sinatra/base'
require 'sinatra/activerecord'

require_relative 'app/constants'
require_relative 'app/scraper/scraper'

# nodoc
class SgShowtimesApi < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :development do
    set :database, adapter: 'sqlite3', database: 'db.sqlite3'

    # Scraper.find_showtimes
  end

  before do
    content_type :json
  end

  def valid_day?(day)
    CONST::WORD_DAY_HASH.key?(day)
  end

  # get information for all movies
  get '/movies' do
    @movies = Movie.includes(:genres).all
    @movies.map(&:gen_json).to_json
  end

  # get information about specific movie
  get '/movie/:id' do
    @movie = Movie.find_by(id: params['id'])

    if @movie
      @movie.gen_json
    else
      halt 404, '404 Movie resource not found'
    end
  end

  # retrieve showtimes
  # today, tomorrow, dayafter supported
  get '/movie/:id/*' do
    day = params['splat'][0]
    @movie = Movie.find_by(id: params['id'])
    halt 404, '404 Movie resource not found' if @movie.nil?
    halt 404, 'Invalid day' unless valid_day?(day)

    @movie.showtimes_json(day)
  end

  error Sinatra::NotFound do
    content_type :text
    status 404
    '404 This is not the endpoint you are looking for.'
  end

  run! if app_file == $PROGRAM_NAME
end
