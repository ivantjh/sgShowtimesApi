require_relative '../models/genre'
require_relative '../models/movie'
require_relative '../models/movie_genres'

# Scrapes movies from nokogiri document and save them to db
module MovieScraper
  def self.is_integer?(text)
    true if Integer(text) rescue false  
  end

  def self.is_float?(text)
    true if Float(text) rescue false
  end

  def self.is_numeric?(text)
    is_float? text or is_integer? text
  end

  def self.trim_detail(detail)
    detail.delete('/').strip
  end

  def self.is_na?(detail)
    detail.upcase === 'NA'
  end

  def self.save_genres(genres)
    genres.each do |genre|
      Genre.create(name: genre) unless Genre.exists?(name: genre)
    end
  end

  def self.find_age_rating(age_rating_str)
    age_rating = trim_detail age_rating_str
    is_na?(age_rating) ? nil : age_rating
  end

  def self.find_language(language_str)
    language_str.strip!

    languages = language_str.split('/')
    languages.each { |lang| lang.strip! }
    # Remove random digits appearing on website
    languages.reject! { |lang| lang.empty? or is_numeric?(lang)}

    return nil if languages.length === 0
    return is_na?(languages[0]) ? nil : languages.join(', ')
  end

  def self.find_genres(genre_str)
    genre_str.strip!

    genres = genre_str.split('/')
    genres.each { |genre| genre.strip! }
    # Remove random digits appearing on website
    genres.reject! { |genre| genre.empty? or is_numeric?(genre)}

    return [] if genres.length === 0
    return is_na?(genres[0]) ? [] : genres
  end

  def self.find_duration(duration_str)
    regex = /(\d+)/ # Extract the numbers only
    duration_str = trim_detail duration_str
    return nil if is_na? duration_str

    grps = duration_str.scan(regex) # find all grps of numbers
    if grps.length === 2
      return Integer(grps[0][0]) * 60 + Integer(grps[1][0])
    elsif grps.length == 1
      return Integer(grps[0][0])
    else
      return nil
    end

    # details[4].split(/[^\d]/).join
  end

  def self.create_movie(details, title, genres)
    Movie.create(
      title: title,
      age_rating: find_age_rating(details[1]),
      language: find_language(details[2]),
      duration_mins: find_duration(details[4]),
      genres: Genre.where(name: genres)
    )
  end

  def self.save_movie(document)
    # spaces in css class is to unwrap enclosing class
    content_class = document.css('.moviedetail-top-content .visible-xs')

    title = content_class.css('h1').text
    movie = Movie.find_by(title: title)
    return movie unless movie.nil?

    details = content_class.css('p small').text.split("\n")
    # details.each_with_index do |d, idx|
    #   puts "#{idx}: #{d}"
    # end

    genres = find_genres(details[3])
    save_genres(genres)

    create_movie(details, title, genres)
  end
end
