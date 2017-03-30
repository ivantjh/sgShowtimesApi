require_relative '../models/movie'

class MovieRoutes < Sinatra::Base
  get '/movies' do
    'hello_world'
  end
end
