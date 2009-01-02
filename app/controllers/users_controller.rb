class UsersController < ApplicationController
  def new
    unless Settings.user_registrations
      flash[:warning] = t('users.new.closed_registration_flash')
      redirect_to root_url
      return
    end
    
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        if Settings.email_activation
          flash[:notice] = t('users.create.email_activation_flash')
        else
          flash[:info] = t('users.create.no_email_activation_flash')
          session[:user_id] = @user.id
        end
        format.html { redirect_to root_url }
      else
        format.html { render :action => "new" }
      end
    end
  end
end
