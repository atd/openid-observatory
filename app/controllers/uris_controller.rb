require 'openid'

class UrisController < ApplicationController
  include ActionController::StationResources

  authorization_filter :forbid, :uri, :only => [ :edit, :update, :destroy ]

  def index
  end

  def create
    realm = "http://#{ request.host_with_port }/"
    return_to = openid_uri_complete_url

    if params[:openid_identifier].present?
      begin
        openid_request = openid_consumer.begin params[:openid_identifier]
      rescue ::OpenID::OpenIDError => e
        flash[:error] = t('openid.client.discovery_failed', :id => params[:openid_identifier], :error => e)
        render :action => 'new'
        return
      end

      if openid_request.send_redirect?(realm, return_to)
        redirect_to openid_request.redirect_url(realm, return_to)
      else
        #FIXME: create 
        @form_text = openid_request.form_markup(realm, return_to, true, { 'id' => 'openid_form' })
        render :partial => 'sessions/openid_form', :layout => nil
      end
    # OpenID login completion
    elsif params[:open_id_complete]
      # Filter path parameters
      parameters = params.reject{ |k,v| request.path_parameters[k] }
      # Complete the OpenID verification process
      openid_response = openid_consumer.complete(parameters, return_to)

      case openid_response.status
      when ::OpenID::Consumer::SUCCESS
        flash[:success] = t('openid.client.verification_succeeded_with_id', :id => openid_response.display_identifier)

        @uri = ::Uri.new(:uri => openid_response.identity_url)

        if @uri.save
          @uri.refresh!

          expire_pages

          redirect_to @uri
        else
          if @uri.errors.count == 1 && @uri.errors.first == ["uri", t('activerecord.errors.messages.taken')]
            # Uri is already saved
            @uri = ::Uri.find_by_uri(@uri.uri)
            @uri.refresh!
            redirect_to @uri
          else
            render :action => 'new'
          end
        end
      when ::OpenID::Consumer::FAILURE
        flash[:error] = openid_response.display_identifier ?
          t('openid.client.verification_failed_with_id', :id => openid_response.display_identifier, :message => openid_response.message) :
          t('openid.client.verification_failed', :message => openid_response.message)
        render :action => 'new'
        return
      when ::OpenID::Consumer::SETUP_NEEDED
        flash[:error] = t('openid.client.immediate_request_failed')
        render :action => 'new'
        return
      when ::OpenID::Consumer::CANCEL
        flash[:error] = t('openid.client.transaction_cancelled')
        render :action => 'new'
        return
      end
    end
  end


  private

  def openid_consumer #:nodoc:
    @openid_consumer ||= ::OpenID::Consumer.new(session,
                                                OpenIdActiveRecordStore.new)
  end

  def expire_pages
    expire_page "/index"
    expire_page "/stats"
  end
end
