class XrdsProperty < ActiveRecord::Migration
  def self.up
    add_column :uri_properties, :xrds_service_types, :text
  end

  def self.down
    remove_column :uri_properties, :xrds_service_types
  end
end
