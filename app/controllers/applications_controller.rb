class ApplicationsController < ApplicationController

  before_filter :ensure_admin
  layout :admin_layout

  def index
    @applications = OauthProviderEngine::Application.all
  end

  def show
    @application = OauthProviderEngine::Application.find(params[:id])
  end

  def new
    @application = OauthProviderEngine::Application.new(params[:oauth_provider_engine_application])
  end

  def create
    @application = OauthProviderEngine::Application.new(params[:oauth_provider_engine_application])
    if @application.save
      redirect_to oauth_provider_engine_applications_path
    else
      render :new
    end
  end

  def edit
    @application = OauthProviderEngine::Application.find(params[:id])
  end

  def update
    @application = OauthProviderEngine::Application.find(params[:id])
    if @application.update_attributes(params[:oauth_provider_engine_application])
      redirect_to @application
    else
      render :edit
    end
  end

  def destroy
    @application = OauthProviderEngine::Application.find(params[:id])
  end

  protected

  def ensure_admin
    OauthProviderEngine.admin_authenticate_method.call(self)
  end

  def admin_layout
    OauthProviderEngine.admin_layout
  end

end
