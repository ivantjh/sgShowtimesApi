class CreateShowtimes < ActiveRecord::Migration[5.0]
  def change
    create_table :showtimes do |t|
      t.datetime :time
      t.integer :movie_id
      t.integer :cinema_id

      t.timestamps
    end

    add_foreign_key :showtimes, :movie_id
    add_foreign_key :showtimes, :cinema_id
  end
end
