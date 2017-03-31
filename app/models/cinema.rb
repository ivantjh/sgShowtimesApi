
require_relative 'showtime'

class Cinema < ActiveRecord::Base
  has_many :showtimes
  has_many :movies, through: :showtimes

  DAY_IN_SECOND = 60 * 60 * 24

  def movie_showtimes(day_no, movie_id)
    # Retrieve showtimes belonging to this cinema and playing movie_id on day_no
    start_time = Time.now.midnight + day_no * DAY_IN_SECOND
    retrieved_showtimes = showtimes
                          .where(
                            cinema_id: id,
                            movie_id: movie_id,
                            datetime: (start_time..start_time + 1.day)
                          )
                          .map(&:to_time_str)

    { cinema: name, showtimes: retrieved_showtimes }.to_json
  end


  # def cinema_showtimes_json(day_no)
  #   { cinema: name, showtimes: Showtime.get_by_day_cinema(day_no, id) }.to_json
  # end
end
