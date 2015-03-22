class Users::SessionsController < Devise::SessionsController
  before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

protected

  def after_sign_in_path_for(resource)
    case current_user.type
    when :student
      root_path
    when :lecturer
      lecturer_path
    when :admin
      admin_path
    else
      root_path
    end
  end

  # You can put the params you want to permit in the empty array.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) << :attribute
  end
end
