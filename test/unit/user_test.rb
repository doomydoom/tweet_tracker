require 'test_helper'
require File.expand_path(File.dirname(__FILE__) + "/../factories/user_factories")

class UserTest < ActiveSupport::TestCase
  should_require_attributes :login, :email

  # All the password validations are run only on a new_record? or if the
  # password is being updated.
  context "A user instance, given a new record or changing password" do
    should_require_attributes :password, :password_confirmation
  end
end
