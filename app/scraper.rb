require 'capybara/poltergeist'
require 'nokogiri'
require 'net/http'

Dir["./models/*"].each {|file| require file}

module Scrapper
  @@url = 'https://www.popcorn.sg/now-showing-trailers-reviews'

  Capybara.register_driver :poltergist do |app|
    Capybara::Poltergeist::Driver.new(app)
  end

  Capybara.default_driver = :poltergeist
  @@browser = Capybara.current_session

  def self.get_showtimes
    @@browser.visit @@url

    movie_href_nodes = @@browser.all(:css, '.img-responsive.thumbnail')
    movie_showtime_links = []

    movie_href_nodes.each do |node|
      movie_showtime_links.push(node[:href])
    end

    uri = URI(movie_showtime_links[0])
    body = Net::HTTP.get(uri)

    document = Nokogiri::HTML(body)
    panels = document.css('.panel.panel-default')

    # Find day separator
    panelNo = panels[0].css('.panel-collapse.collapse.in').attr("id")
    puts panelNo

    cinema = panels[0].css('.panel-title h4').text

    timing_nodes = panels[0].css('.row')
    puts cinema

    timing_nodes.each do |node|
      location = node.css('.col-md-12.col-sm-12.col-xs-12.cinemaname').text
      timings = node.css('li a')

      puts location
      timings.each { |t| puts t.text }
    end
  end
end
