class AddDepthToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :depth, :integer, :default => 0
  end

  def self.down
    remove_column :comments, :depth
  end
end
