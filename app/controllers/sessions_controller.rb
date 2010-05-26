class SessionsController < ApplicationController
  before_filter :redirect

  private

  def redirect
    redirect_to new_uri_path
  end
end
