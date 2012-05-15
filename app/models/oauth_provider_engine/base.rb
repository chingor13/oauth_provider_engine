module OauthProviderEngine
  class Base < ActiveRecord::Base
    self.abstract_class = true
  end
end
