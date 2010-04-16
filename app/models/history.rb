class History < ActiveRecord::Base
  class << self
    def record
      create :date => Date.today,
             :uris_count => Uri.count
    end
  end

  validates_presence_of :date, :uris_count
  validates_uniqueness_of :date
end
