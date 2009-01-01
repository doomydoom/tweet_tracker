require 'test_helper'
require File.expand_path(File.dirname(__FILE__) + "/../factories/user_factories")
require 'digest/sha2'

class UserTest < ActiveSupport::TestCase
  test "Should be invalid without a login" do
    @user = Factory.build(:new_user, :login => nil)
    assert ! @user.valid?
    assert @user.errors.on(:login)
    @user.login = 'joeuser'
    assert @user.valid?
  end

  test "Should be invalid without an email" do
    @user = Factory.build(:new_user, :email => nil)
    assert ! @user.valid?
    assert @user.errors.on(:email)
    @user.email = 'joeuser@domain.com'
    assert @user.valid?
  end

  test "Should be invalid without a password" do
    @user = Factory.build(:new_user, :password => nil)
    assert ! @user.valid?
    assert @user.errors.on(:password)
    @user.password = 'a1b2c3'
    assert @user.valid?
  end

  test "Should be invalid without a password_confirmation" do
    @user = Factory.build(:new_user, :password_confirmation => nil)
    assert ! @user.valid?
    assert @user.errors.on(:password_confirmation)
    @user.password_confirmation = 'a1b2c3'
    assert @user.valid?
  end

  test "Should be invalid with too short of a password" do
    @user = Factory.build(:new_user)
    @user.password = @user.password_confirmation = 'x' * (User::PASSWORD_MIN_LENGTH - 1)
    assert ! @user.valid?
    assert @user.errors.on(:password)
    @user.password = @user.password_confirmation = 'x' * User::PASSWORD_MIN_LENGTH  
    assert @user.valid?
  end

  test "Should be invalid with too short a login" do
    @user = Factory.build(:new_user)
    @user.login = 'x' * (User::LOGIN_MIN_LENGTH - 1)
    assert ! @user.valid?
    assert @user.errors.on(:login)
    @user.login = 'x' * User::LOGIN_MIN_LENGTH
    assert @user.valid?
  end

  test "Should be invalid with too long of a login" do
    @user = Factory.build(:new_user)
    @user.login = 'x' * (User::LOGIN_MAX_LENGTH + 1)
    assert ! @user.valid?
    assert @user.errors.on(:login)
    @user.login = 'x' * User::LOGIN_MAX_LENGTH
    assert @user.valid?
  end

  test "Should be invalid with an invalidly formatted login" do
    @user = Factory.build(:new_user)
    @user.login = 'joe-user'
    assert ! @user.valid?
    assert @user.errors.on(:login)
    @user.login = 'joe_user'
    assert ! @user.valid?
    assert @user.errors.on(:login)
    @user.login = 'joeuser'
    assert @user.valid?
    @user.login = 'JoeUser'
    assert @user.valid?
  end

  test "should not be valid with invalid email format" do
    @user = Factory.build(:new_user)
    @user.email = 'joeuseratdomain.com'
    assert ! @user.valid?
    assert @user.errors.on(:email)
    assert_equal('must be in the format [user@domain.com]', @user.errors.on(:email))
    @user.email = 'joeuser@domaincom'
    assert ! @user.valid?
    assert @user.errors.on(:email)
    assert_equal('must be in the format [user@domain.com]', @user.errors.on(:email))
    @user.email = 'joeuser@domain.com'
    assert @user.valid?
  end

  test "should create a salt, and then hash the salt with SHA256" do
    @user = User.create!(Factory.attributes_for(:new_user))
    assert_not_nil @user.password_salt
    assert_equal(64, @user.password_salt.length)
  end

  test "should create a crypted_password which is a combination of the password and salt" do
    @user = User.create!(Factory.attributes_for(:new_user))
    expected_crypted_password = Digest::SHA256.hexdigest("--#{@user.password_salt}--#{@user.password}--")
    assert_not_nil @user.crypted_password
    assert_equal(64, @user.crypted_password.length)
    assert_equal(expected_crypted_password, @user.crypted_password)
  end

  test "should generate a activation_token if email activation is enabled" do
    @user = User.create!(Factory.attributes_for(:new_user))
    # Since the default email_activation is true, we are sure it's enabled
    assert_not_nil @user.activation_token
    # Activation token is a SHA256 hash, so it should be 64 chars
    assert_equal(64, @user.activation_token.length)
    # activated_on should be nil since the user has not been activated
    assert_nil @user.activated_at
  end

  test "should set the activated_at date and leave activation_token nil if email_activation is false" do
    @user = Factory.build(:new_user)
    Settings.email_activation = false
    @user.save
    assert_not_nil @user.activated_at
    assert_nil @user.activation_token
  end

  test "should return true if the user is already activated" do
    @user = Factory.build(:new_user)
    Settings.email_activation = false
    @user.save
    assert @user.activated?        
  end

  test "should return false if the user is not already activated" do
    @user = Factory(:new_user)
    assert ! @user.activated?
  end

  test "should clean the login string before validation" do
    @user = Factory(:new_user, :login => ' Joe User ') # This would be invalid normally
    assert @user.valid?
    assert_equal('joeuser', @user.login)
  end

  test "should clean the email string before validation" do
    @user = Factory(:new_user, :email => ' JoeUser @ Domain.Com ') # should be invalid
    assert @user.valid?
    assert_equal('joeuser@domain.com', @user.email)
  end

  test "should strip the spaces before and after the user's password" do
    @user = Factory(:new_user, :password => ' a1b2c3 ', :password_confirmation => ' a1b2c3 ')
    assert @user.valid?
    assert_equal('a1b2c3', @user.password)
    assert_equal('a1b2c3', @user.password_confirmation)
  end

  test "should be invalid if login already exists" do
    Factory(:new_user)
    @user = Factory.build(:new_user)
    assert ! @user.valid?
    assert @user.errors.on(:login)
    assert_equal('has already been taken', @user.errors.on(:login))
  end

  test "should be invalid if email already exists" do
    Factory(:new_user)
    @user = Factory.build(:new_user)
    assert ! @user.valid?
    assert @user.errors.on(:email)
    assert_equal('has already been taken', @user.errors.on(:email))
  end

  test "should not require a password if the password is not being updated" do
    Factory(:new_user)
    @user = User.find_by_login('joeuser')
    @user.login = 'joeuser2'
    @user.save
    assert @user.valid?
  end

  test "should require a password if updating_password is set" do
    Factory(:new_user)
    @user = User.find_by_login('joeuser')
    @user.login = 'joeuser2'
    @user.updating_password = true
    @user.save
    assert ! @user.valid?
    assert @user.errors.on(:password)
  end

  test "should be invalid if password and password_confirmation do not match" do
    @user = Factory.build(:new_user, :password_confirmation => 'c1b2a3')
    assert ! @user.valid?
    assert @user.errors.on(:password)
    assert_equal("doesn't match confirmation", @user.errors.on(:password))
  end 
end
