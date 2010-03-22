class UriProperties < ActiveRecord::Migration
  def self.up
    create_table :uri_properties do |t|
      t.references :uri
      t.boolean :foaf
      t.boolean :feeds
      t.boolean :atompub
      t.boolean :rsd
      t.text :microformats
    end
  end

  def self.down
    drop_table :uri_properties
  end
end
