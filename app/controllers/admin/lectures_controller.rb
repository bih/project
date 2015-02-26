class Admin::LecturesController < ApplicationController
  before_filter :admin_lecturer_only!
  before_filter :admin_only!, only: [:destroy]
  before_filter :set_lecture, only: [:add_student, :copy_students, :remove_student, :register, :register_student, :show, :edit, :update, :destroy]

  def index
    if current_user.admin?
      @units = Unit.paginate(:page => params[:page]).all
      @lectures = Lecture.all
    else
      @units = Unit.paginate(:page => params[:page]).where_leader(current_user)
      @lectures = @units.map{ |unit| unit.lectures }.flatten
    end
  end

  def new
    @lecture = Lecture.new
    @unit = params[:unit]
  end

  def create
    @lecture = Lecture.new(lecture_params)

    if @lecture.save
      redirect_to admin_lectures_path, notice: 'Class created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @lecture.update_attributes(lecture_params)

    if @lecture.save
      redirect_to admin_lectures_path, notice: 'Class updated.'
    else
      render :edit
    end
  end

  def destroy
    @lecture.destroy
    redirect_to admin_lectures_path, notice: 'Class destroyed.'
  end

  def show
    @lecture_student = LectureStudent.new
    @students_to_add = User.where_type(:student).for_form.select{ |a| @lecture.lecture_students.map{ |ls| ls.user_id }.include?(a[1]) == false }
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
        redirect_to admin_lecture_register_path(@lecture), notice: "#{@student.name} has already been registered for this class."
      end
    else
      redirect_to admin_lecture_register_path(@lecture), notice: "Student with MMU ID #{student_id} does not exist or is not in this class."
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
