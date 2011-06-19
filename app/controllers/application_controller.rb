class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  def set_locale
    I18n.locale = current_user.setting(:language)  if current_user
  end

  def check_bitcoin_keys
    if !current_user || !current_user.keys_loaded?
      sign_out
      return redirect_to new_user_session_path
    end
  end

end
