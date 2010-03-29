require 'openid'

class UrisController < ApplicationController
  include ActionController::StationResources

  authorization_filter :forbid, :uri, :only => [ :edit, :update, :destroy ]

  def index
  end

  def create
    @uri = ::Uri.new(params[:uri])

    if @uri.save
      @uri.refresh!
      redirect_to @uri
    else
      if @uri.errors.count == 1 && @uri.errors.first == ["uri", t('activerecord.errors.messages.taken')]
        @uri = ::Uri.find_by_uri(@uri.uri)
        @uri.refresh!
        redirect_to @uri
      else
        render :action => 'index'
      end
    end
  end
end
