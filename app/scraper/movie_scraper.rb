require_relative '../models/genre'
require_relative '../models/movie'
require_relative '../models/movie_genres'

# Scrapes movies from nokogiri document and save them to db
module MovieScraper
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

  def self.create_movie(details, title, genres)
    Movie.create(
      title: title,
      age_rating: find_age_rating(details),
      language: find_language(details),
      duration_mins: find_duration(details),
      genres: Genre.where(name: genres)
    )
  end

  def self.save_movie(document)
    title = document.css('.visible-xs h1').text
    movie = Movie.find_by(title: title)

    return movie unless movie.nil?
    details = document.css('.visible-xs p small').text.split("\n")
    genres = find_genres(details)
    save_genres(genres)

    create_movie(details, title, genres)
  end
end
