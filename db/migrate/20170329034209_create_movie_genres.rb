class CreateMovieGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :movie_genres do |t|
      t.integer :movie_id
      t.integer :genre_id
    end

    add_foreign_key :movie_genres, :movie_id
    add_foreign_key :movie_genres, :genre_id
  end
end
