class Showtime < ActiveRecord::Base
  DAY_IN_SECOND = 60 * 60 * 24

  belongs_to :movie
  belongs_to :cinema

  def to_time_str
    datetime.localtime.iso8601
  end

  # def self.get_by_cinema(cinema_id)
  #   Showtimes.where(cinema_id: cinema_id)
  # end
  #
  # def self.get_by_movie(movie_id)
  #   Showtimes.where(movie_id: movie_id)
  # end
  #
  # def self.get_by_day_cinema(day_no, cinema_id)
  #   start_time = Time.now.midnight + day_no * day_in_second
  #   get_by_cinema(cinema_id).where(datetime: start_time..start_time + 1.day)
  # end
  #
  # def self.get_by_day_movie(day_no, movie_id)
  #   start_time = Time.now.midnight + day_no * day_in_second
  #   get_by_movie(movie_id).where(datetime: start_time..start_time + 1.day)
  # end
end
