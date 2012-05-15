module OauthProviderEngine
  class AccessToken < OauthProviderEngine::Base

    belongs_to :application, :class_name => "::OauthProviderEngine::Application"

    before_validation :generate_keys
    validates_presence_of :application_id, :user_id, :token, :secret
    validates_numericality_of :application_id, :user_id, :allow_nil => true

    protected

    def generate_keys
      self.token ||= OauthProviderEngine.generate_key
      self.secret ||= OauthProviderEngine.generate_key
    end
  end
end
