require_relative '../constants'
require_relative 'cinema'

# nodoc
class Movie < ActiveRecord::Base
  has_many :showtimes
  has_many :cinemas, through: :showtimes
  has_many :movie_genres
  has_many :genres, through: :movie_genres

  def gen_json
    movie_hash = attributes
    movie_hash[:genres] = genres.map(&:name)
    movie_hash
  end

  def find_showtimes_by_cinema(showtimes, cinema)
    showtimes
      .select { |showtime| showtime.cinema_id == cinema.id }
      .map(&:to_time_str)
  end

  # Formats showtimes obj
  def showtimes_by_cinemas_json(day_no)
    start_time = Time.now.midnight + day_no * CONST::DAY_IN_SECOND
    @showtimes = showtimes
                 .includes(:cinema)
                 .where(datetime: (start_time..start_time + 1.day))

    cinemas = @showtimes.map(&:cinema).uniq
    cinemas.map do |cinema|
      { cinema: cinema.name,
        showtimes: find_showtimes_by_cinema(@showtimes, cinema) }
    end
  end

  # Provides json for a specific day
  def showtimes_json(day)
    showtimes_by_cinemas_json(CONST::WORD_DAY_HASH[day]).to_json
  end
end
