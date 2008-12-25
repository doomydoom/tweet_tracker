class UsersController < ApplicationController
  def new
    unless Settings.user_registrations
      flash[:warning] = t('users.new.closed_registration_flash')
      redirect_to root_url
      return
    end
    
    @user = User.new
  end
end
