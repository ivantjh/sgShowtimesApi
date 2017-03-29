class MovieGenre < ActiveRecord::Base
  belongs_to :movie
  belongs_to :genre
end
