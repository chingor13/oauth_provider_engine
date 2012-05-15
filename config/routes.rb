Rails.application.routes.draw do

  match "/oauth/authorize", :to => "oauth#authorize"
  match "/oauth/request_token", :to => "oauth#request_token"
  match "/oauth/access_token", :to => "oauth#access_token"

  namespace :oauth_provider_engine, :path => "oauth" do
    resources :applications
  end

end
