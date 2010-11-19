class AddProcessedToLink < ActiveRecord::Migration
  def self.up
    add_column :links, :processed, :boolean, :default => false
  end

  def self.down
    remove_column :links, :processed
  end
end
