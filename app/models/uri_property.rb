class UriProperty < ActiveRecord::Base
  belongs_to :uri

  serialize :xrds_service_types, Array
end
