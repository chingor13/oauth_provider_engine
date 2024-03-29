class OauthController < ApplicationController

  layout nil

  # ignore the csrf token
  skip_before_filter :verify_authenticity_token

  before_filter :ensure_logged_in, :only => [:authorize]
  before_filter :load_application, :except => [:authorize]

  def authorize
    # ensure we have a valid request token
    @request_token = OauthProviderEngine::RequestToken.where(:token => params[:oauth_token]).first
    return render_403("invalid request token") unless @request_token

    # check to see if the user has already authorized
    user_id = OauthProviderEngine.user_method.call(self)
    if @access_token = OauthProviderEngine::AccessToken.not_expired.for_user(user_id).first
      @request_token.authorize!(user_id)
      render_authorize_success(@request_token)
      return
    end

    if request.post?
      # create an access token for the current user
      @request_token.authorize!(user_id)
      render_authorize_success(@request_token)
    else
      # render the allow/disallow form
      @application = @request_token.application
      render :authorize, :layout => OauthProviderEngine.oauth_layout
    end
  end

  def request_token
    # ensure that the OAuth request was properly signed
    return render_401("invalid signature") unless OAuth::Signature.verify(oauth_request, :consumer_secret => @application.secret)

    @request_token = @application.request_tokens.build()
    @request_token.save

    render :text => @request_token.to_query
  end

  def access_token
    token = params.fetch(:oauth_token, oauth_params.fetch("oauth_token"))
    @request_token = OauthProviderEngine::RequestToken.authorized.where(:token => token).first

    # ensure we have a valid request token
    return render_403("invalid request token") unless @request_token

    # ensure that the OAuth request was properly signed
    return render_401("invalid signature") unless OAuth::Signature.verify(oauth_request, :consumer_secret => @application.secret, :token_secret => @request_token.secret) 

    if @access_token =  OauthProviderEngine::AccessToken.not_expired.for_user(@request_token.user_id).first
      # user already has a valid access token
      @request_token.destroy
    else
      # upgrade the request token to an access token (deletes the request token)
      @access_token = @request_token.upgrade!
    end

    render :text => @access_token.to_query
  end

  protected

  def ensure_logged_in
    OauthProviderEngine.authenticate_method.call(self)
  end

  def oauth_request
    @oauth_request ||= OAuth::RequestProxy.proxy(request)
  end

  def oauth_params
    @oauth_params ||= oauth_request.parameters
  end

  def load_application
    @application = OauthProviderEngine::Application.where(:key => oauth_params.fetch("oauth_consumer_key")).first
    render_403('invalid application') unless @application.present?
  end

  def render_401(message)
    render :text => message, :status => 401
  end

  def render_403(message)
    render :text => message, :status => 403
  end

  def render_authorize_success(request_token)
    callback_uri = URI.parse(params.fetch(:oauth_callback, request_token.application.url))
    token_params = {
      :oauth_token => request_token.token
    }.to_query
    if callback_uri.query.present?
      callback_uri.query = callback_uri.query + "&" + token_params
    else
      callback_uri.query = token_params
    end
    redirect_to callback_uri.to_s
  end

end
