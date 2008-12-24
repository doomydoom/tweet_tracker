# == Schema Information
# Schema version: 20081222183043
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  login               :string(20)
#  email               :string(255)
#  crypted_password    :string(64)
#  password_salt       :string(64)
#  activation_token    :string(64)
#  activated_at        :datetime
#  remember_me_token   :string(64)
#  remember_me_expires :datetime
#  timezone            :string(255)
#  language            :string(2)
#  created_at          :datetime
#  updated_at          :datetime
#

require 'digest/sha2'
class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation, :updating_password
  attr_accessible :login, :password, :password_confirmation, :email, :language,
                  :timezone 

  LOGIN_MIN_LENGTH = 4
  LOGIN_MAX_LENGTH = 20
  LOGIN_LENGTH_RANGE = LOGIN_MIN_LENGTH..LOGIN_MAX_LENGTH
  PASSWORD_MIN_LENGTH = 6

  validates_presence_of     :login, :email

  validates_length_of       :login,
                            :in => LOGIN_LENGTH_RANGE,
                            :allow_blank => true

  validates_uniqueness_of   :login, :email

  validates_format_of       :login,
                            :with =>  /^[0-9a-z]+$/i,
                            :message => "can only contain letters and numbers",
                            :allow_blank => true

  validates_format_of       :email,
                            :with =>  /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i,
                            :message => "must be in the format [user@domain.com]",
                            :allow_blank => true   


  # We only want to check password validations if the password is being changed
  # or on a new record, so we seperate them out.
  validates_presence_of     :password, :password_confirmation,
                            :if => :changing_password

  validates_confirmation_of :password,
                            :if => :changing_password

  validates_length_of       :password,
                            :minimum => PASSWORD_MIN_LENGTH,
                            :allow_blank => true

  before_save               :generate_salt_and_crypted_password
   

  protected

  # validation_callbacks

  # Returns updating_password?
  # Used with the password validations in a callback on :if
  def changing_password
    return updating_password?
  end

  # before_save callbacks

  # generates both the user's salt and crypted password. The salt is
  # regenerated each time the password is changed for a little better security
  def generate_salt_and_crypted_password
    self.password_salt = Digest::SHA256.hexdigest("--#{Time.now}--#{self.login}--")
    self.crypted_password = Digest::SHA256.hexdigest("--#{self.password_salt}--#{self.password}--")
  end

  private

  # Returns true if the record is new, or the updating_password attribute has
  # been set to true.
  def updating_password?
    new_record? or updating_password
  end
end
