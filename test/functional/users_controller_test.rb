require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "on GET to :new with user_registrations enabled" do
    Settings.user_registrations = true
    get :new
    assert assigns(:user)
    assert_response :success
    assert_template 'new'
    # Since open registrations is active, you should not have any flash showing.
    assert_nil flash[:warning]
    assert_select "form[action=?]", "/users"
    assert_select "form p", :count => 6
  end

  test "on GET to :new with user_registrations disabled" do
    Settings.user_registrations = false
    get :new
    assert_redirected_to root_url
    assert_not_nil flash[:warning]
    assert_equal(I18n.t('users.new.closed_registration_flash'), flash[:warning])
  end

end
