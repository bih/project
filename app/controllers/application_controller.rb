class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Render 404 pages in controllers.
  def render_404!
    render :file => File.join(Rails.root, 'public', '404.html'), :status => 404, :layout => false
    return true
  end

  def is_logged_in!
    return render_404! unless signed_in?
  end

  def admin_only!
    return render_404! unless signed_in?
    return render_404! unless current_user.admin?
  end

  def lecturer_only!
    return render_404! unless signed_in?
    return render_404! unless current_user.lecturer?
  end

  def unit_leader_only!
    return render_404! unless signed_in?
    return render_404! if not current_user.lecturer? and not current_user.is_unit_leader?
  end

  def student_only!
    return render_404! unless signed_in?
    return render_404! unless current_user.student?
  end

  def admin_lecturer_only!
    return render_404! unless signed_in?
    return render_404! unless current_user.admin? or current_user.lecturer?
    return render_404! if current_user.lecturer? and not params[:type].nil? and params[:type] != "student" and (not current_user.is_unit_leader? or params[:type] != "lecturer")
  end

  def admin_unit_leader_only!
    return render_404! unless signed_in?
    return render_404! unless current_user.admin? or current_user.is_unit_leader?
    return render_404! if current_user.lecturer? and not params[:type].nil? and params[:type] != "student" and (not current_user.is_unit_leader? or params[:type] != "lecturer")
  end
end
