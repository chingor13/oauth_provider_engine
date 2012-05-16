Rails.application.routes.draw do

  match "/oauth/authorize", :to => "oauth#authorize"
  match "/oauth/request_token", :to => "oauth#request_token"
  match "/oauth/access_token", :to => "oauth#access_token"

  scope "/oauth" do
    resources :applications, :as => "oauth_provider_engine_applications"
  end

end
