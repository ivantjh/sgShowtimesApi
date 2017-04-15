require 'sinatra/base'
require 'sinatra/activerecord'

require_relative 'app/constants'
require_relative 'app/scraper/scraper'

# nodoc
class SgShowtimesApi < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  before do
    content_type :json
  end

  def invalid_day_err
    s = ''
    s << 'Invalid day. Only accepts '

    CONST::WORD_DAY_HASH.each_with_index do |(key, value), index|
      s << "'#{key}'"
      s << ', ' if index < CONST::WORD_DAY_HASH.length - 2
      s << ' or ' if index == CONST::WORD_DAY_HASH.length - 2
    end

    s
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
  get '/movies/:id' do
    @movie = Movie.find_by(id: params['id'])

    if @movie
      @movie.gen_json.to_json
    else
      halt 404, '404 Movie resource not found'
    end
  end

  # retrieve showtimes
  # today, tomorrow and dayafter supported
  get '/movies/:id/*' do
    day = params['splat'][0]
    @movie = Movie.find_by(id: params['id'])
    halt 404, '404 Movie resource not found' if @movie.nil?
    halt 404, invalid_day_err unless valid_day?(day)

    @movie.showtimes_json(day)
  end

  get '/cinemas' do
    Cinema.all.to_json
  end

  get '/cinemas/:id' do
    @cinema = Cinema.find_by(id: params['id'])

    if @cinema
      @cinema.to_json
    else
      halt 404, '404 Cinema resource not found'
    end
  end

  get '/cinemas/:id/*' do
    day = params['splat'][0]
    @cinema = Cinema.find_by(id: params['id'])
    halt 404, '404 Cinema resource not found' if @cinema.nil?
    halt 404, invalid_day_err unless valid_day?(day)

    @cinema.showtimes_json(day)
  end

  error Sinatra::NotFound do
    content_type :text
    status 404
    '404 This is not the endpoint you are looking for.'
  end

  run! if app_file == $PROGRAM_NAME
end
