class Admin::UsersController < ApplicationController
  before_filter :admin_lecturer_only!
  before_filter :set_user, :only => [:show, :edit, :update, :destroy]
  before_filter :set_type, :only => [:index, :new, :edit, :update, :destroy]

  def index
    @users = User.paginate(:page => params[:page], :per_page => 30).where_type(@type).all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: "#{@user.type.capitalize} has been created!"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user.update_attributes(user_params)

    if @user.save
      redirect_to admin_users_path, notice: "#{@user.first_name.capitalize} has been updated!"
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User has been deleted."
  end

protected

  def set_user
    @user = User.find(params[:id])
  end

  def set_type
    @type = (params[:type] || @user.type).to_s.downcase.to_sym rescue :student
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :course_name, :mmu_id, :email, :password, :password_confirmation, :account_type, :audit_comment)
  end

  def get_attendance

  end
end
