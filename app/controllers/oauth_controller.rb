class OauthController < ApplicationController

  layout nil

  # ignore the csrf token
  skip_before_filter :verify_authenticity_token

  before_filter :ensure_logged_in, :only => [:authorize]
  before_filter :load_application, :except => [:authorize]

  def authorize
    @request_token = OauthProviderEngine::RequestToken.where(:token => params[:oauth_token]).first
    @application = @request_token.application

    if request.post?
      # create an access token for the current user
      @request_token.authorize!(OauthProviderEngine.user_method.call(self))
      callback_uri = URI.parse(params.fetch(:oauth_callback, @request_token.application.url))
      token_params = {
        :oauth_token => @request_token.token
      }.to_query
      if callback_uri.query.present?
        callback_uri.query = callback_uri.query + "&" + token_params
      else
        callback_uri.query = token_params
      end
      redirect_to callback_uri.to_s
    else
      # render the allow/disallow form
      render :authorize, :layout => OauthProviderEngine.oauth_layout
    end
  end

  def request_token
    @request_token = @application.request_tokens.build()
    @request_token.save
    render :text => {
      :oauth_token => @request_token.token,
      :oauth_token_secret => @request_token.secret
    }.to_query
  end

  def access_token
    token = params.fetch(:oauth_token, @oauth_params.fetch("oauth_token"))
    @request_token = OauthProviderEngine::RequestToken.authorized.where(:token => token).first

    @access_token = @request_token.upgrade!

    render :text => {
      :oauth_token => @access_token.token,
      :oauth_token_secret => @access_token.secret
    }.to_query
  end

  protected

  def ensure_logged_in
    OauthProviderEngine.authenticate_method.call(self)
  end

  def load_application
    @oauth_params = OAuth::Helper.parse_header(request.headers['HTTP_AUTHORIZATION'])
    @application = OauthProviderEngine::Application.where(:key => @oauth_params.fetch("oauth_consumer_key")).first

    raise(ActiveRecord::RecordNotFound) unless @application.present?
  end

end
