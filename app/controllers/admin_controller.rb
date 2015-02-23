class AdminController < ApplicationController
  before_filter :admin_lecturer_only!

  def index
    if current_user.admin?
      render :index
    else
      render :"lecturer/index"
    end
  end
end
