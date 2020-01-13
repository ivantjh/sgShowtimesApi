require_relative '../constants'
require_relative '../models/showtime'
require_relative '../models/cinema'

# Scrapes showtimes from nokogiri document and save them to db
module ShowtimeScraper
  def self.get_date_from_day(day)
    # puts day
    Time.now + CONST::DAY_IN_SECOND * CONST::TAB_NUM_DAY_HASH[day]
  end

  def self.convert_12h_to_24h(hour, time_period)
    hour = 0 if (time_period == 'AM' && hour == 12)
    hour += 12 if (time_period == 'PM' && hour != 12)
    hour
  end

  def self.combine_date_time(date, time_str)
    # This is needed because there may be some random values behind the time str
    time_str = time_str[/[0-9]{1,2}:[0-9]{2}(AM|PM)/]

    # pad with zero if time_str is not complete 12 hr time, need to be '07:30PM' and not '7:30PM'
    time_str = '0' + time_str if time_str.length != 7

    time_period = time_str.last(2) # gets the last 2 characters 'AM' or 'PM'
    hour = convert_12h_to_24h(time_str.first(2).to_i, time_period)
    min = time_str[3..4].to_i

    Time.new(date.year, date.month, date.day, hour, min, 0, date.utc_offset)
  end

  def self.save_cinema(name)
    cinema = Cinema.find_by(name: name)
    cinema = Cinema.create(name: name) if cinema.nil?
    cinema
  end

  def self.save_showtime(movie_id, cinema_id, datetime)
    args = { movie_id: movie_id, cinema_id: cinema_id, datetime: datetime }
    showtime = Showtime.find_by(**args)
    Showtime.create(**args) if showtime.nil?
  end

  def self.add_showtimes_to_db(movie_id, cinema_id, timings, date)
    timings.each do |time|
      save_showtime(movie_id, cinema_id, combine_date_time(date, time.text))
    end
  end

  def self.save_showtimes(document, movie_id)
    # document.attr('id') gets the attribute of id in html
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
