class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :language
      t.string :age_rating
      t.integer :duration_mins
    end
  end
end
