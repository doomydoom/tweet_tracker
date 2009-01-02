require 'test_helper'
require File.expand_path(File.dirname(__FILE__) + "/../factories/user_factories")


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

  test "on POST to :create with valid attributes, with email activation enabled" do
    Settings.email_activation = true
    assert_difference 'User.count' do
      post :create, :user => Factory.attributes_for(:new_user)  
    end  
    assert_redirected_to root_url
    assert_not_nil flash[:notice]
    assert_nil session[:user_id]
    assert_equal(I18n.t('users.create.email_activation_flash'), flash[:notice])
  end

  test "on POST to :create with valid attributes, with email activation disabled" do
    Settings.email_activation = false
    assert_difference 'User.count' do
      post :create, :user => Factory.attributes_for(:new_user)
    end
    assert_redirected_to root_url
    assert_not_nil flash[:info]
    assert_not_nil session[:user_id]
    assert_equal(I18n.t('users.create.no_email_activation_flash'), flash[:info])
  end

  test "on POST to :create with invalid attributes" do
    assert_no_difference 'User.count' do
      post :create, :user => Factory.attributes_for(:new_user, :password => 'c1b2a3')  
    end
    assert_template 'new'
  end

end
