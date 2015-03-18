class Admin::LecturesController < ApplicationController
  before_filter :admin_lecturer_only!
  before_filter :admin_only!, only: [:destroy]
  before_filter :set_lecture, only: [:add_student, :copy_students, :remove_student, :register, :register_student, :show, :edit, :update, :destroy]

  def index
    if current_user.admin?
      @units = Unit.paginate(:page => params[:page]).all
      @lectures = Lecture.all
    else
      @units = Unit.where_leader_or_teaches_in(current_user)
      @lectures = @units.map{ |unit| unit.lectures.select{ |lecture| lecture.user == current_user or lecture.unit.leaders.include?(current_user) } }.flatten
    end
  end

  def on_day
    @day = params.include?(:date) ? Time.parse(params[:date]) : Time.now
    @day_text = "on #{@day.day.ordinalize} #{@day.strftime("%B %Y")}"
    @day_text = "yesterday" if @day.to_date == Date.yesterday
    @day_text = "today" if @day.to_date == Date.today
    @day_text = "tomorrow" if @day.to_date == Date.tomorrow
    @lectures = Lecture.on_day(@day).order('start_time ASC')

    @lectures = @lectures.select{ |lecture| lecture.user == current_user or lecture.unit.leaders.include?(current_user) } if current_user.lecturer?
  end

  def get_units_and_lecturers
    @units = Unit.for_form
    @units = Unit.for_form_and_part_of_unit(current_user.teaches_in_or_leaders_of) if current_user.lecturer?

    @lecturers = User.where_type(:lecturer).for_form
  end

  def new
    @lecture = Lecture.new
    @unit = params[:unit]

    get_units_and_lecturers
  end

  def create
    @lecture = Lecture.new(lecture_params)

    get_units_and_lecturers

    if @lecture.save
      redirect_to admin_lectures_path, notice: "Class '#{@lecture.name}' created."
    else
      render :new
    end
  end

  def edit
    get_units_and_lecturers
  end

  def update
    @lecture.update_attributes(lecture_params)

    get_units_and_lecturers

    if @lecture.save
      redirect_to admin_unit_lectures_path(@lecture.unit), notice: "Class '#{@lecture.name}' updated."
    else
      render :edit
    end
  end

  def destroy
    @lecture.destroy
    redirect_to admin_lectures_path, notice: "Class '#{@lecture.name}' destroyed."
  end

  def show
    @lecture_student = LectureStudent.new
    @students_to_add = User.where_type(:student).for_form.select{ |a| @lecture.lecture_students.map{ |ls| ls.user_id }.include?(a.first) == false }
  end

  def add_student
    @lecture.lecture_students.create(lecture_student_params)
    redirect_to admin_lecture_path(@lecture)
  end

  def copy_students
    @copy = Lecture.find(params[:lecture_to_copy_id])
    @students_to_copy = @copy.students - @lecture.students

    @students_to_copy.each do |student|
      @lecture.lecture_students.create(user_id: student.id)
    end

    redirect_to admin_lecture_path(@lecture), notice: "#{@students_to_copy.count} students were added to your class."
  end

  def remove_student
    @lecture.lecture_students.where(user_id: params['id']).destroy_all
    redirect_to admin_lecture_path(@lecture)
  end

  def register
  end

  def register_student
    student_id = params['student_id']

    if student_id[0...4] == ";300"
      student_id = student_id[4...-2]
    end

    @student = User.where_type(:student).find_by_mmu_id(student_id)

    if @student && @lecture.students.include?(@student)
      if @lecture.check_in_student!(@student)
        redirect_to admin_lecture_register_path(@lecture), notice: "#{@student.name} has successfully registered their attendance for this class."
      else
        redirect_to admin_lecture_register_path(@lecture), alert: "#{@student.name} has already been registered for this class."
      end
    else
      redirect_to admin_lecture_register_path(@lecture), alert: "Student with MMU ID #{student_id} does not exist or is not in this class."
    end
  end

  def download
  end

protected

  def set_lecture
    @lecture = Lecture.find(params[:lecture_id] || params[:id])
  end

  def lecture_params
    params.require(:lecture).permit(:lecture_name, :lecture_room, :lecture_type, :unit_id, :user_id, :start_time, :end_time, :audit_comment)
  end

  def lecture_student_params
    params.require(:lecture_student).permit(:user_id)
  end
end
