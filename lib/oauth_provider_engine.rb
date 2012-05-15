require 'oauth'
require 'oauth/request_proxy/rack_request'
module OauthProviderEngine

  class << self
    # this method is used to protect the oauth#authenticate action.  you should check to
    #   see if the user is logged in.  if the user is not logged in, redirect them to 
    #   your login page. upon successful login, they should be redirected back to the
    #   authenticate action with the same oauth_token param
    class_attribute :authenticate_method
    self.authenticate_method = Proc.new{|c| raise "need to override the authenticate method"}

    # this method is used to protect the applications controller.  if you do not protect the controller,
    #   anyone can create their own applications (which is a valid scenario).
    class_attribute :admin_authenticate_method
    self.admin_authenticate_method = Proc.new{|c| raise "need to override the admin authenticate method"}

    # this proc should be used to fetch the uniq user id from the controller
    class_attribute :user_method
    self.user_method = Proc.new{|c| raise "need to override the method of retrieving the user id"}

    # these settings allow you to specify what layout to use for the applications resource and the 
    #   oauth authorize page
    class_attribute :admin_layout
    class_attribute :oauth_layout

    # this setting lets you specify the expiry on an access_token
    class_attribute :access_token_expiry

    def generate_key(length = 32)
      Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand(1000)}--")[0,length-1]
    end

    def configure(opts = {})
      opts.each do |k,v|
        self.send("#{k}=", v)
      end

      yield self if block_given?
    end
  end
end

require 'oauth_provider_engine/version'
require 'oauth_provider_engine/engine'
