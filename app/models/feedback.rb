class Feedback < ActiveRecord::Base
  validates_presence_of :email, :subject, :content

  acts_as_resource 

  # Implement params_from_atom for AtomPub support
  # Return hash with content attributes
  def self.params_from_atom(entry)
    # Example:
    # { :body => entry.content.xml.to_s }
    {}
  end
end
