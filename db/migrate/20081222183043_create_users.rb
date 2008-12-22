class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table    :users do |t|
      t.string      :login,              :limit => 20
      t.string      :email
      t.string      :crypted_password,   :limit => 64
      t.string      :password_salt,      :limit => 64
      t.string      :activation_token,   :limit => 64
      t.datetime    :activated_at
      t.string      :remember_me_token,  :limit => 64
      t.datetime    :remember_me_expires
      t.string      :timezone
      t.string      :language,           :limit => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
