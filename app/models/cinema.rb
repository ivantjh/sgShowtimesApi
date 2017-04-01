require_relative 'showtime'

# nodoc
class Cinema < ActiveRecord::Base
  has_many :showtimes
  has_many :movies, through: :showtimes
end
