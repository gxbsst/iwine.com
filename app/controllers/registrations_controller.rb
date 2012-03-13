class RegistrationsController < Devise::RegistrationsController
  
  protected

  def after_sign_up_path_for(resource)
    "/mine"
  end
  
  def after_inactive_sign_up_path_for(resource)
    "/users/register/success?email=#{resource.email}"
  end
end

