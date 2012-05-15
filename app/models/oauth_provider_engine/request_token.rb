module OauthProviderEngine
  class RequestToken < OauthProviderEngine::Base

    belongs_to :application, :class_name => "::OauthProviderEngine::Application"

    before_validation :generate_keys
    validates_presence_of :application_id, :token, :secret
    validates_numericality_of :application_id, :allow_nil => true

    scope :authorized, where("user_id is not null")

    def authorize!(user_id)
      update_attribute(:user_id, user_id)
    end

    # this method with upgrade the RequestToken to an AccessToken
    #   note that this will destroy the current RequestToken
    def upgrade!
      access_token = nil
      transaction do
        access_token = OauthProviderEngine::AccessToken.create!({
          :application_id => self.application_id,
          :user_id => self.user_id,
        })
        self.destroy || raise(ActiveRecord::Rollback)
      end
      return access_token
    end

    def to_query
      {
        :oauth_token => token,
        :oauth_token_secret => secret
      }.to_query
    end

    protected

    def generate_keys
      self.token ||= OauthProviderEngine.generate_key
      self.secret ||= OauthProviderEngine.generate_key
    end
  end
end
