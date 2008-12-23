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

class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation, :updating_password

  validates_presence_of     :login, :email

  # We only want to check password validations if the password is being changed
  # or on a new record, so we seperate them out.
  validates_presence_of     :password, :password_confirmation,
                            :if => :changing_password
  validates_confirmation_of :password,
                            :if => :changing_password
   

  protected

  # validation_callbacks

  # Returns updating_password?
  # Used with the password validations in a callback on :if
  def changing_password
    return updating_password?
  end

  private

  # Returns true if the record is new, or the updating_password attribute has
  # been set to true.
  def updating_password?
    new_record? or updating_password
  end
end