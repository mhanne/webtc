class AdminController < ApplicationController

  before_filter :authenticate_user!, :only_admin

  def index
    @users = User.all
    @page_title = t('admin.index.title')
  end

  def show
    @user = User.find(params[:id])
    @addresses = @user.addresses
    @page_title = t('admin.show.title', :email => @user.email)
  end

  private

  def only_admin
    return redirect_to new_user_session_path  unless current_user && current_user.is_admin?
  end

end
