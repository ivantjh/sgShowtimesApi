require 'capybara/poltergeist'
require 'nokogiri'
require 'net/http'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/models/*') {|file| require file}

module Scrapper
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
    movie = Movie.new

    movie.title = document.css('.visible-xs h1').text
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
      if !Genre.exists?(:name => genre)
        Genre.create(name: genre)
      end
    end

    if !Movie.exists?(:title => movie.title)
      movie.genres = Genre.where(name: genres)
      movie.save
    end
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

    save_movie document

    # panel contains cinema name and showtime
    # tab_panes = document.css('.tab-pane') + document.css('.tab-pane.active')
    # tab_panes.each do |tab_pane|
    #   day = tab_pane.attr("id")
    #   puts day
    #
    #   tab_pane.css('.panel.panel-default').each do |panel_default|
    #     # cinema = pd.css('.panel-title h4').text
    #
    #     panel_default.css('.row').each do |row|
    #       location = row.css('.col-md-12.col-sm-12.col-xs-12.cinemaname').text
    #       timings = row.css('li a')
    #
    #       puts location
    #       timings.each { |t| puts t.text }
    #     end
    #   end
    # end

  end
end
