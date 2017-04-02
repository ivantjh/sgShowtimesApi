require 'capybara/poltergeist'
require 'nokogiri'
require 'net/http'

require_relative '../db_interface'
require_relative 'movie_scraper'
require_relative 'showtime_scraper'

# Main Scraper module
module Scraper
  @url = 'https://www.popcorn.sg/now-showing-trailers-reviews'

  Capybara.register_driver :poltergist do |app|
    Capybara::Poltergeist::Driver.new(app)
  end

  Capybara.default_driver = :poltergeist
  @browser = Capybara.current_session

  def self.find_movie_links
    @browser.visit @url

    movie_href_nodes = @browser.all(:css, '.img-responsive.thumbnail')
    movie_showtime_links = []

    movie_href_nodes.each do |node|
      movie_showtime_links.push(node[:href])
    end

    movie_showtime_links
  end

  def self.scrape_showtimes(document, movie_id)
    # panel contains cinema name and showtime
    tab_panes = document.css('.tab-pane') + document.css('.tab-pane.active')
    tab_panes.each do |tab_pane|
      ShowtimeScraper.save_showtimes(tab_pane, movie_id)
    end
  end

  def self.start_scraper
    Db.init_connection
    movie_showtime_links = find_movie_links

    movie_showtime_links.each do |link|
      uri = URI(link)
      body = Net::HTTP.get(uri)
      document = Nokogiri::HTML(body)

      movie = MovieScraper.save_movie(document)
      scrape_showtimes(document, movie.id)
    end
  end
end
