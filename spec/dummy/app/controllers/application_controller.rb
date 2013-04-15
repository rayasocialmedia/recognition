class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  def current_user
    return User.last
  end
end
