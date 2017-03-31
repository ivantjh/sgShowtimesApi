class Showtime < ActiveRecord::Base
  belongs_to :movie
  belongs_to :cinema

  def to_time_str
    datetime.localtime
    # iso8601
  end
end
