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
end
