require_relative 'showtime'

# nodoc
class Cinema < ActiveRecord::Base
  has_many :showtimes
  has_many :movies, through: :showtimes

  def find_showtimes_by_movie(showtimes, movie)
    showtimes
      .select { |showtime| showtime.movie_id == movie.id}
      .map(&:to_time_str)
  end

  def showtimes_by_movies_json(day_no)
    start_time = Time.now.midnight + day_no * CONST::DAY_IN_SECOND

    @showtimes = showtimes
                  .includes(:movie)
                  .where(datetime: (start_time..start_time + 1.day))

    # movies.uniq is needed because there
    # are many showtime records tying one movie and one cinema togther
    movies.uniq.map do |movie|
      { movie: movie.title,
        showtimes: find_showtimes_by_movie(@showtimes, movie)}
    end
  end

  def showtimes_json(day)
    showtimes_by_movies_json(CONST::WORD_DAY_HASH[day]).to_json
  end
end
