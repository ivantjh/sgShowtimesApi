require_relative 'db_interface'
require_relative './models/movie'
require_relative './models/showtime'

# nodoc
module Maintenance
  def self.remove_old_movies
    Movie.all.each do |movie|
      movie.destroy if movie.showtimes.empty?
    end
  end

  def self.remove_old_showtimes
    # Only keep records for a day before
    Showtime.where('datetime < ?', Time.now.midnight - 1.day).destroy_all
  end

  def self.run
    Db.init_connection

    remove_old_showtimes
    remove_old_movies
  end
end
