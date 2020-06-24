class Statistics < ActiveRecord::Migration[6.0]
  def change
    create_table :statistics do |t|
      t.string :name, null: false, default: ''
      t.integer :value, null: false, default: 0
    end
  end
end
