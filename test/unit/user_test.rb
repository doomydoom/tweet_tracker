require 'test_helper'
require File.expand_path(File.dirname(__FILE__) + "/../factories/user_factories")

class UserTest < ActiveSupport::TestCase
  should_require_attributes :login, :email

  # All the password validations are run only on a new_record? or if the
  # password is being updated.
  context "A user instance, given a new record or changing password" do
    should_require_attributes :password, :password_confirmation

    # Shoulda has no checks for confirmation, so we write one.
    should "be invalid if password and password_confirmation do not match" do
      @user = Factory.build(:new_user, :password_confirmation => 'c1b2a3')
      assert ! @user.valid?
      assert_equal("doesn't match confirmation", @user.errors.on(:password))
    end
  end
end
