require 'jbuilder'
require_relative 'cinema'

# nodoc
class Movie < ActiveRecord::Base
  has_many :showtimes
  has_many :cinemas, through: :showtimes
  has_many :movie_genres
  has_many :genres, through: :movie_genres

  def to_builder
    Jbuilder.new do |movie|
      movie.id id
      movie.language language
      movie.title title
      movie.age_rating age_rating
      movie.duration_mins duration_mins

      movie.genres genres.map(&:name)
    end
  end

  # def to_showtimes_builder
  #   movie.showtimes.cinema.each do |cinema|
  #   end
  #
  #   # to_builder
  # end

  # Formats showtimes obj
  def showtimes_by_cinema_json(day_no)
    # cinemas.each { |c| puts c.name }
    cinemas.uniq.map { |c| c.movie_showtimes(day_no, id) }
  end

  # def retrieve_showtimes(day_no)
  #   day_in_second = 60 * 60 * 24
  #   start_time = Time.now.midnight + day_no * day_in_second
  #   st = showtimes.where(datetime: (start_time..start_time + 1.day))
  #
  #   format_cinema_showtimes_json(st)
  # end

  # provides json for today, tmrw and dayafter
  def showtimes_json


    Jbuilder.new do |movie|
      movie.today showtimes_by_cinema_json(0)
      # movie.tomorrow
      # movie.dayafter
    end
  end

end
