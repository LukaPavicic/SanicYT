class CreateInfo < ActiveRecord::Migration[6.0]
  def change
    create_table :infos do |t|
      t.integer :songs_downloaded
    end
  end
end
