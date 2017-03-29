class Movie < ActiveRecord::Base
  has_many :showtimes
  has_many :movie_genres
  has_many :genres, through: :movie_genres
end
