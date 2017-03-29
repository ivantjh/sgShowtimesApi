require 'capybara/poltergeist'
require 'nokogiri'
require 'net/http'

require_relative 'movie_scraper'
require_relative 'showtime_scraper'


module Scrapper
  @day_in_second = 60 * 60 * 24
  @url = 'https://www.popcorn.sg/now-showing-trailers-reviews'

  Capybara.register_driver :poltergist do |app|
    Capybara::Poltergeist::Driver.new(app)
  end

  Capybara.default_driver = :poltergeist
  @browser = Capybara.current_session


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

    movie = MovieScraper.save_movie(document)

    # panel contains cinema name and showtime
    tab_panes = document.css('.tab-pane') + document.css('.tab-pane.active')
    tab_panes.each do |tab_pane|
      ShowtimeScraper.save_showtimes(tab_pane, movie.id)
      # tab_pane.css('.panel.panel-default').each do |panel_default|
      #   panel_default.css('.row').each do |row|
      #     cinema_name = row.css('.col-md-12.col-sm-12.col-xs-12.cinemaname').text
      #     cinema = save_cinema(cinema_name)
      #     timings = row.css('li a')
      #
      #     timings.each do |time|
      #       save_showtimes(movie.id, cinema.id, time.text, date)
      #     end
      #   end
      # end
    end
  end
end
