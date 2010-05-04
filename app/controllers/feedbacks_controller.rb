class FeedbacksController < ApplicationController
  # Include CRUD methods.
  #
  # You can overwritte them if you need it, but consider adding 
  # the functionality in the Model
  include ActionController::StationResources

  authorization_filter :forbid, :feedback, :except => [ :new, :create ]

end
