require 'capybara/poltergeist'
require 'nokogiri'
require 'net/http'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/models/*') { |file| require file }

module Scrapper
  @day_in_second = 60 * 60 * 24
  @url = 'https://www.popcorn.sg/now-showing-trailers-reviews'

  Capybara.register_driver :poltergist do |app|
    Capybara::Poltergeist::Driver.new(app)
  end

  Capybara.default_driver = :poltergeist
  @browser = Capybara.current_session

  def self.trim_detail(detail)
    detail.delete(' /')
  end

  def self.save_genres(genres)
    genres.each do |genre|
      Genre.create(name: genre) unless Genre.exists?(name: genre)
    end
  end

  def self.find_age_rating(details)
    trim_detail details[1]
  end

  def self.find_language(details)
    trim_detail details[2]
  end

  def self.find_genres(details)
    genre_str = details[3]
    genre_str[0..genre_str.length - 3].split(' / ')
  end

  def self.find_duration(details)
    details[4].split(/[^\d]/).join
  end

  def self.save_movie(document)
    title = document.css('.visible-xs h1').text
    movie = Movie.find_by(title: title)

    return movie unless movie.nil?
    details = document.css('.visible-xs p small').text.split("\n")
    genres = find_genres(details)
    save_genres(genres)

    Movie.create(
      title: title,
      age_rating: find_age_rating(details),
      language: find_language(details),
      duration_mins: find_duration(details),
      genres: Genre.where(name: genres)
    )
  end

  def self.save_cinema(name)
    cinema = Cinema.find_by(name: name)
    cinema = Cinema.create(name: name) if cinema.nil?
    cinema
  end

  def self.save_showtimes(movie_id, cinema_id, time_str, date)
    time_str = time_str[/[0-9]{2}:[0-9]{2}(AM|PM)/]
    time_period = time_str.last(2)
    hour = time_str.first(2).to_i
    min = time_str[3..4].to_i

    hour = 0 if time_period == 'AM' && hour == 12
    hour += 12 if time_period == 'PM' && hour != 12

    time = Time.new(date.year, date.month, date.day, hour, min, 0, '+08:00')

    showtime = Showtime.find_by(
      movie_id: movie_id,
      cinema_id: cinema_id,
      time: time
    )

    return unless showtime.nil?
    Showtime.create(
      movie_id: movie_id,
      cinema_id: cinema_id,
      time: time
    )
  end

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

  def self.find_showtimes
    @browser.visit @url

    movie_href_nodes = @browser.all(:css, '.img-responsive.thumbnail')
    movie_showtime_links = []

    movie_href_nodes.each do |node|
      movie_showtime_links.push(node[:href])
    end

    uri = URI(movie_showtime_links[1])
    body = Net::HTTP.get(uri)
    document = Nokogiri::HTML(body)

    movie = save_movie document

    # panel contains cinema name and showtime
    tab_panes = document.css('.tab-pane') + document.css('.tab-pane.active')
    tab_panes.each do |tab_pane|
      date = get_date_from_day(tab_pane.attr('id'))

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
