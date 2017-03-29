require_relative '../models/showtime'
require_relative '../models/cinema'

# Scrapes showtimes from nokogiri document and save them to db
module ShowtimeScraper
  @day_in_second = 60 * 60 * 24

  def self.get_date_from_day(day)
    day_no_hash = {
      'today' => 0,
      'tomorrow' => 1,
      'dayafter' => 2,
      'dayafter2' => 3,
      'dayafter3' => 4,
      'dayafter4' => 5
    }

    Time.now + @day_in_second * day_no_hash[day]
  end

  def self.convert_12h_to_24h(hour, time_period)
    hour = 0 if time_period == 'AM' && hour == 12
    hour = 12 if time_period == 'PM' && hour != 12
    hour
  end

  def self.combine_date_time(date, time_str)
    time_str = time_str[/[0-9]{2}:[0-9]{2}(AM|PM)/]
    time_period = time_str.last(2)
    hour = convert_12h_to_24h(time_str.first(2).to_i, time_period)
    min = time_str[3..4].to_i

    Time.new(date.year, date.month, date.day, hour, min, 0, date.utc_offset)
  end

  def self.save_cinema(name)
    cinema = Cinema.find_by(name: name)
    cinema = Cinema.create(name: name) if cinema.nil?
    cinema
  end

  def self.save_showtime(movie_id, cinema_id, time)
    args = { movie_id: movie_id, cinema_id: cinema_id, time: time }
    showtime = Showtime.find_by(**args)
    Showtime.create(**args) if showtime.nil?
  end

  def self.add_showtimes_to_db(movie_id, cinema_id, timings, date)
    timings.each do |time|
      save_showtime(movie_id, cinema_id, combine_date_time(date, time.text))
    end
  end

  def self.save_showtimes(document, movie_id)
    date = get_date_from_day(document.attr('id'))

    document.css('.panel.panel-default').each do |panel_default|
      panel_default.css('.row').each do |row|
        cinema_name = row.css('.col-md-12.col-sm-12.col-xs-12.cinemaname').text
        cinema = save_cinema(cinema_name)
        timings = row.css('li a')

        add_showtimes_to_db(movie_id, cinema.id, timings, date)
      end
    end
  end
end
