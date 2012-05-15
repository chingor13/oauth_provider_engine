module OauthProviderEngine
  class AccessToken < OauthProviderEngine::Base

    belongs_to :application, :class_name => "::OauthProviderEngine::Application"

    before_validation :generate_keys
    before_create :generate_expiry
    validates_presence_of :application_id, :user_id, :token, :secret
    validates_numericality_of :application_id, :user_id, :allow_nil => true

    scope :expired, where("expires_at <= NOW()")
    scope :not_expired, where("expires_at IS NULL OR expires_at > NOW()")
    scope :for_user, lambda{|user_id| where(:user_id => user_id)}

    def to_query
      params = {
        :oauth_token => token,
        :oauth_token_secret => secret
      }
      params[:oauth_authorization_expires_at] = expires_at.to_i if expires_at.present?
      params.to_query
    end

    protected

    def generate_keys
      self.token ||= OauthProviderEngine.generate_key
      self.secret ||= OauthProviderEngine.generate_key
    end

    def generate_expiry
      return true unless OauthProviderEngine.access_token_expiry

      if OauthProviderEngine.access_token_expiry.respond_to?(:call)
        self.expires_at = OauthProviderEngine.access_token_expiry.call(self)
      else
        self.expires_at = Time.now + OauthProviderEngine.access_token_expiry
      end
    end
  end
end
