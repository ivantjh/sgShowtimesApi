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

    # panel contains cinema name and showtime
    tab_panes = document.css('.tab-pane') + document.css('.tab-pane.active')
    tab_panes.each do |tab_pane|
      day = tab_pane.attr("id")
      puts day

      tab_pane.css('.panel.panel-default').each do |panel_default|
        # cinema = pd.css('.panel-title h4').text

        panel_default.css('.row').each do |row|
          location = row.css('.col-md-12.col-sm-12.col-xs-12.cinemaname').text
          timings = row.css('li a')

          puts location
          timings.each { |t| puts t.text }
        end
      end
    end

  end
end
