module OauthProviderEngine
  class Application < OauthProviderEngine::Base
    has_many :access_tokens, :class_name => "::OauthProviderEngine::AccessToken", :dependent => :destroy
    has_many :request_tokens, :class_name => "::OauthProviderEngine::RequestToken", :dependent => :destroy

    before_validation :generate_keys

    validates_presence_of :name, :url, :key, :secret
    attr_accessible :name, :url

    validate do
      errors.add(:url, "is invalid") unless URI.parse(url)
    end

    protected

    def generate_keys
      self.key ||= OauthProviderEngine.generate_key
      self.secret ||= OauthProviderEngine.generate_key
    end
  end
end
