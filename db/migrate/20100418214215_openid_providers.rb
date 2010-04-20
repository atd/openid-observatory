class OpenidProviders < ActiveRecord::Migration
  def self.up
    add_column :uri_properties, :openid_providers, :text
  end

  def self.down
    remove_column :uri_properties, :openid_providers
  end
end
