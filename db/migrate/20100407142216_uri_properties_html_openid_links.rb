class UriPropertiesHtmlOpenidLinks < ActiveRecord::Migration
  def self.up
    add_column :uri_properties, :link_openid_server, :boolean
    add_column :uri_properties, :link_openid2_provider, :boolean
  end

  def self.down
    remove_column :uri_properties, :link_openid_server
    remove_column :uri_properties, :link_openid2_provider
  end
end
