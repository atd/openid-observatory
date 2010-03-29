class DifferentiateFeeds < ActiveRecord::Migration
  def self.up
    remove_column :uri_properties, :feeds
    add_column :uri_properties, :atom, :boolean
    add_column :uri_properties, :rss, :boolean
  end

  def self.down
    add_column :uri_properties, :feeds, :boolean
    remove_column :uri_properties, :atom
    remove_column :uri_properties, :rss
  end
end
