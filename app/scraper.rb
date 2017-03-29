require 'capybara/poltergeist'
require 'nokogiri'
require 'net/http'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/models/*') {|file| require file}

module Scrapper
  @@day_in_second = 60 * 60 * 24
  @@url = 'https://www.popcorn.sg/now-showing-trailers-reviews'

  Capybara.register_driver :poltergist do |app|
    Capybara::Poltergeist::Driver.new(app)
  end

  Capybara.default_driver = :poltergeist
  @@browser = Capybara.current_session

  def self.trim_detail detail
    detail.delete(' /')
  end

  def self.save_movie document
    title = document.css('.visible-xs h1').text
    movie = Movie.find_by(title: title)

    if movie.nil?
      movie = Movie.new
      details = document.css('.visible-xs p small').text.split("\n")
      details.shift

      genres = []

      details.each_with_index do |detail, index|
        case index
        when 0
          movie.age_rating = trim_detail detail
        when 1
          movie.language = trim_detail detail
        when 2
          genres = detail[0..detail.length - 3].split ' / '
        when 3
          movie.duration_mins = detail.split(/[^\d]/).join
        end
      end

      genres.each do |genre|
        if !Genre.exists?(name: genre)
          Genre.create(name: genre)
        end
      end

      movie.title = title
      movie.genres = Genre.where(name: genres)
      movie.save
    end

    movie
  end

  def self.save_cinema name
    cinema = Cinema.find_by(name: name)
    if cinema.nil?
      cinema = Cinema.create(name: name)
    end

    cinema
  end

  def self.save_showtimes(movie_id, cinema_id, time_str, date)
    time_str = time_str[/[0-9]{2}:[0-9]{2}(AM|PM)/]
    time_period = time_str.last(2)
    hour = time_str.first(2).to_i
    min = time_str[3..4].to_i

    if time_period == 'AM' && hour == 12
      hour = 0
    end

    if time_period == 'PM' && hour != 12
      hour += 12
    end

    time = Time.new(date.year, date.month, date.day, hour, min, 0, "+08:00")

    showtime = Showtime.find_by(movie_id: movie_id, cinema_id: cinema_id, time: time)
    if showtime.nil?
      Showtime.create(movie_id: movie_id, cinema_id: cinema_id, time: time)
    end
  end

  def self.get_date_from_day day
    day_no_hash = { "today" => 0, "tomorrow" => 1, "dayafter" => 2,
      "dayafter2" => 3, "dayafter3" => 4, "dayafter4" => 5 }

    Time.now + @@day_in_second * day_no_hash[day]
  end

  def self.get_showtimes
    @@browser.visit @@url

    movie_href_nodes = @@browser.all(:css, '.img-responsive.thumbnail')
    movie_showtime_links = []

    movie_href_nodes.each do |node|
      movie_showtime_links.push(node[:href])
    end

    uri = URI(movie_showtime_links[1])
    body = Net::HTTP.get(uri)
    document = Nokogiri::HTML(body)

    movie = save_movie document
    # puts movie.inspect

    # panel contains cinema name and showtime
    tab_panes = document.css('.tab-pane') + document.css('.tab-pane.active')
    tab_panes.each do |tab_pane|
      date = get_date_from_day(tab_pane.attr("id"))
      # puts date

      tab_pane.css('.panel.panel-default').each do |panel_default|
        panel_default.css('.row').each do |row|
          cinema_name = row.css('.col-md-12.col-sm-12.col-xs-12.cinemaname').text
          cinema = save_cinema(cinema_name)
          timings = row.css('li a')

          timings.each do |time|
            save_showtimes(movie.id, cinema.id, time.text, date)
          end
        end
      end
    end

  end
end
