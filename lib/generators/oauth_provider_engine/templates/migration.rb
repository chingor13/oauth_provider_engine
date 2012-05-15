class CreateOauthProviderEngineTables < ActiveRecord::Migration

  def self.up
    create_table :applications do |t|
      t.string :name
      t.string :url
      t.string :key
      t.string :secret
    end

    create_table :access_tokens do |t|
      t.integer :application_id
      t.string :token
      t.string :secret
      t.integer :user_id
      t.datetime :expires_at
    end

    create_table :request_tokens do |t|
      t.integer :application_id
      t.string :token
      t.string :secret
      t.integer :user_id
    end
  end

  def self.down
    drop_table :request_tokens
    drop_table :access_tokens
    drop_table :applications
  end

end
