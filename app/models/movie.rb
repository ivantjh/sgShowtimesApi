require 'jbuilder'
require_relative '../constants'
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

  def find_showtimes_by_cinema(showtimes, cinema)
    showtimes
      .select { |showtime| showtime.cinema_id == cinema.id }
      .map(&:to_time_str)
  end

  # Formats showtimes obj
  def showtimes_by_cinema_json(day_no)
    # cinemas.uniq.map { |c| c.movie_showtimes(day_no, id) }
    start_time = Time.now.midnight + day_no * CONST::DAY_IN_SECOND
    @showtimes = showtimes.includes(:cinema).where(datetime: (start_time..start_time + 1.day))

    cinemas = @showtimes.map(&:cinema).uniq
    cinemas.map do |cinema|
      { cinema: cinema.name, showtimes: find_showtimes_by_cinema(@showtimes, cinema) }
    end
  end

  # provides json for today, tmrw and dayafter
  def showtimes_json(day)
    showtimes_by_cinema_json(CONST::WORD_DAY_HASH[day]).to_json
  end
end
