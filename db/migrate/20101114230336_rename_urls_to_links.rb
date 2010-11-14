class RenameUrlsToLinks < ActiveRecord::Migration
  def self.up
    rename_table :urls, :links
  end

  def self.down
  end
end
