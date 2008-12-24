require 'test_helper'
require File.expand_path(File.dirname(__FILE__) + "/../factories/user_factories")
require 'digest/sha2'

class UserTest < ActiveSupport::TestCase
  should_require_attributes :login, :email

  should_ensure_length_in_range :login, (User::LOGIN_LENGTH_RANGE)

  should_protect_attributes :created_on, :updated_on, :remember_me_token,
                            :remember_me_expires, :activation_token,
                            :activated_at, :crypted_password, :salt

  should_not_allow_values_for :login, "joe-user", "joe_user",
                              :message => "can only contain letters and numbers"

  should_allow_values_for :login, "JoeUser", "joeuser"

  should_not_allow_values_for :email, "joeuseratdomain.com", "joeuser@domaincom",
                              :message => "must be in the format [user@domain.com]"

  should "create a salt, and then hash the salt with SHA256" do
    @user = User.create!(Factory.attributes_for(:new_user))
    assert_not_nil @user.password_salt
    assert_equal(64, @user.password_salt.length)
  end

  should "create a crypted_password which is a combination of the password and salt" do
    @user = User.create!(Factory.attributes_for(:new_user))
    expected_crypted_password = Digest::SHA256.hexdigest("--#{@user.password_salt}--#{@user.password}--")
    assert_not_nil @user.crypted_password
    assert_equal(64, @user.crypted_password.length)
    assert_equal(expected_crypted_password, @user.crypted_password)
  end

  should "generate a activation_token if email activation is enabled" do
    @user = User.create!(Factory.attributes_for(:new_user))
    # Since the default email_activation is true, we are sure it's enabled
    assert_not_nil @user.activation_token
    # Activation token is a SHA256 hash, so it should be 64 chars
    assert_equal(64, @user.activation_token.length)
    # activated_on should be nil since the user has not been activated
    assert_nil @user.activated_at
  end

  should "set the activated_at date and leave activation_token nil if email_activation is false" do
    @user = Factory.build(:new_user)
    Settings.email_activation = false
    @user.save
    assert_not_nil @user.activated_at
    assert_nil @user.activation_token
  end

  should "should return true if the user is already activated" do
    @user = Factory.build(:new_user)
    Settings.email_activation = false
    @user.save
    assert @user.activated?
  end

  should "return false if the user is not already activated" do
    @user = Factory(:new_user)
    assert ! @user.activated?
  end

  should "clean the login string before validation" do
    @user = Factory(:new_user, :login => ' Joe User ') # This would be invalid normally
    assert @user.valid?
    assert_equal('joeuser', @user.login)
  end

  should "clean the email string before validation" do
    @user = Factory(:new_user, :email => ' JoeUser @ Domain.Com ') # should be invalid
    assert @user.valid?
    assert_equal('joeuser@domain.com', @user.email)
  end

  should "strip the spaces before and after the user's password" do
    @user = Factory(:new_user, :password => ' a1b2c3 ', :password_confirmation => ' a1b2c3 ')
    assert @user.valid?
    assert_equal('a1b2c3', @user.password)
    assert_equal('a1b2c3', @user.password_confirmation)
  end

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
