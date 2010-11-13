class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :urls do |t|
      t.string :uri
      t.string :name
      t.text :description
      t.integer :created_by

      t.timestamps
    end
  end

  def self.down
    drop_table :urls
  end
end
