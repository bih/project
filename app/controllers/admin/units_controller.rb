class Admin::UnitsController < ApplicationController
  before_filter :admin_only!
  before_filter :set_unit, only: [:create_leader, :delete_leader, :lectures, :show, :edit, :update, :destroy]

  def index
    @units = Unit.paginate(:page => params[:page], :per_page => 30).all
  end

  def show
    @unit_lecturer = UnitLecturer.new
    @lecturers_to_add = User.where_type(:lecturer).for_form.select{ |a| @unit.unit_lecturers.map{ |ul| ul.user_id }.include?(a[1]) == false }
  end

  def lectures
  end

  def create_leader
    @unit.add_leader!(unit_leader_params[:user_id])
    redirect_to admin_unit_path(@unit)
  end

  def delete_leader
    @unit.remove_leader!(params[:id])
    redirect_to admin_unit_path(@unit)
  end

  def new
    @unit = Unit.new
  end

  def create
    @unit = Unit.new(unit_params)

    if @unit.save
      redirect_to admin_unit_path(@unit)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @unit.update_attributes(unit_params)

    if @unit.save
      redirect_to admin_units_path
    else
      render :edit
    end
  end

  def destroy
    @unit.destroy
    redirect_to admin_units_path, notice: "Unit destroyed."
  end

protected

  def set_unit
    @unit = Unit.find(params[:unit_id] || params[:id])
  end

  def unit_params
    params.require(:unit).permit(:unit_name, :unit_year, :unit_code, :audit_comment)
  end

  def unit_leader_params
    params.require(:unit_lecturer).permit(:user_id)
  end
end
