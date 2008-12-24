require 'test_helper'
require File.expand_path(File.dirname(__FILE__) + "/../factories/user_factories")

class UserTest < ActiveSupport::TestCase
  should_require_attributes :login, :email

  should_ensure_length_in_range :login, (User::LOGIN_LENGTH_RANGE)

  should_protect_attributes :created_on, :updated_on, :remember_me_token,
                            :remember_me_expires, :activation_token,
                            :activated_at, :crypted_password, :salt

  should_not_allow_values_for :login, "joe-user", "joe_user", "joe user",
                              :message => "can only contain letters and numbers"

  should_allow_values_for :login, "JoeUser", "joeuser"

  should_not_allow_values_for :email, "joeuseratdomain.com", "joeuser@domaincom",
                              :message => "must be in the format [user@domain.com]"


  # Because of the way Shoulda works for uniqueness of, I am pulling these
  # out to their own contexts to avoid using a fixture.
  context "A user instance given an already existing record" do
    setup do
      @user = User.create!(Factory.attributes_for(:new_user))
    end

    should_require_unique_attributes :login, :email

    should "not require a password if the password is not being updated" do
      @user = User.find_by_login('joeuser')
      @user.login = 'joeuser2'
      @user.save
      assert @user.valid?
    end

    should "require a password if updating_password is set" do
      @user = User.find_by_login('joeuser')
      @user.login = 'joeuser2'
      @user.updating_password = true
      @user.save
      assert ! @user.valid?
      assert @user.errors.on(:password)
    end
  end

  # All the password validations are run only on a new_record? or if the
  # password is being updated.
  context "A user instance, given a new record or changing password" do
    should_require_attributes :password, :password_confirmation

    should_ensure_length_at_least :password, User::PASSWORD_MIN_LENGTH

    # Shoulda has no checks for confirmation, so we write one.
    should "be invalid if password and password_confirmation do not match" do
      @user = Factory.build(:new_user, :password_confirmation => 'c1b2a3')
      assert ! @user.valid?
      assert_equal("doesn't match confirmation", @user.errors.on(:password))
    end
  end
end
