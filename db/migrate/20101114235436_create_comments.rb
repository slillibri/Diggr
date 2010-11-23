class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.text :description
      t.integer :user_id
      t.integer :link_id

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
