class Unit < ActiveRecord::Base
  has_many :lectures
  has_many :unit_lecturers

  validates :unit_name, :presence => true
  validates :unit_code, :presence => true
  validates :unit_year, :presence => true

  validates_uniqueness_of :unit_code
  
  audited

  before_destroy do
    Lecture.where_unit(id).destroy_all
    UnitLecturer.where_unit(id).destroy_all
  end

  def self.for_form
    all.map{ |u| [u.unit_name, u.id] }
  end

  def self.for_form_and_part_of_unit(units)
    units.map{ |u| [u.unit_name, u.id] }
  end

  def self.where_leader(user)
    UnitLecturer.where_user(user.id || user.to_i).map{ |ul| ul.unit }
  end

  def self.where_leader_or_teaches_in(user)
    a = UnitLecturer.where_user(user.id || user.to_i).map{ |ul| ul.unit }
    b = Lecture.where_user(user.id || user.to_i).map{ |l| l.unit }

    (a + b).flatten.uniq.sort
  end

  def self.where_student(user)
    @units = []

    LectureStudent.where_user(user.id || user.to_i).each do |ls|
      @units << ls.lecture.unit
    end

    @units.uniq
  end

  def add_leader!(user_id)
    user_id = user_id.id if user_id.class == User
    unit_lecturers.new(user_id: user_id).save
  end

  def remove_leader!(user_id)
    user_id = user_id.id if user_id.class == User
    unit_lecturers.where(user_id: user_id).first.destroy
  end

  def leaders
    leader_ids = unit_lecturers.map{ |ul| ul.user_id }
    User.find(leader_ids)
  end

  def leaders_include_relationships
    unit_lecturers.map{ |ul| [ul, User.find(ul.user_id)] }
  end

  def students
    students = []

    lectures.each do |lecture|
      students << lecture.students
    end

    students.flatten.uniq
  end

  def lectures_in_past
    lectures.select{ |l| l.has_finished? }.uniq
  end

  def lectures_in_future
    lectures.reject{ |l| l.has_finished? }.uniq
  end

  def attendance
    attendance_of_lectures = lectures.map{ |a| a.attendance }
    (attendance_of_lectures.sum / attendance_of_lectures.count)
  end

  def attendance_by_weeks
    weeks_attendance = {}
    weeks_punctuality = {}
    weeks = {}

    lectures_in_past.each do |lecture|
      weeks[lecture.start_time.strftime('%U')] ||= []

      weeks_attendance[lecture.start_time.strftime('%U')] ||= []
      weeks_attendance[lecture.start_time.strftime('%U')] << lecture.attendance

      weeks_punctuality[lecture.start_time.strftime('%U')] ||= []
      weeks_punctuality[lecture.start_time.strftime('%U')] << lecture.average_minutes_to_class
    end

    weeks.each do |week, _|
      weeks[week] = [
        ((weeks_attendance[week].sum / weeks_attendance[week].count).round rescue 100),
        ((weeks_punctuality[week].sum / weeks_punctuality[week].count).round rescue 0)
      ]
    end

    weeks
  end

  def attendance_by_lecture_types
    types_attendance = {}
    types_punctuality = {}
    types = {}

    lectures_in_past.each do |lecture|
      types[lecture.lecture_type] ||= []

      types_attendance[lecture.lecture_type] ||= []
      types_attendance[lecture.lecture_type] << lecture.attendance

      types_punctuality[lecture.lecture_type] ||= []
      types_punctuality[lecture.lecture_type] << lecture.average_minutes_to_class
    end

    types.each do |type, _|
      types[type] = [
        ((types_attendance[type].sum / types_attendance[type].count).round rescue 100),
        ((types_punctuality[type].sum / types_punctuality[type].count).round rescue 0)
      ]
    end

    types
  end

  def attendance_by_course
    course_attendance = {}
    course_punctuality = {}
    courses = {}

    lectures_in_past.each do |lecture|
      lecture.students.each do |student|
        courses[student.course_name] ||= []

        course_attendance[student.course_name] ||= []
        course_attendance[student.course_name] << (lecture.attendance_of_student(student) ? 100.0 : 0.0)

        course_punctuality[student.course_name] ||= []
        course_punctuality[student.course_name] << lecture.average_minutes_of_student(student)
      end
    end

    courses.each do |course, _|
      courses[course] = [
        ((course_attendance[course].sum / course_attendance[course].count).round rescue 100),
        ((course_punctuality[type].sum / course_punctuality[course].count).round rescue 0)
      ]
    end

    courses
  end

  def add_lecture!(lecturer, type, lecture)
    Lecture.create!({ unit_id: id, user_id: lecturer.id, lecture_type: type.to_s }.merge(lecture))
  end

  def lecturers
    lecturers = []

    lectures.each do |lecture|
      lecturers << lecture.lecturer
    end

    lecturers.uniq
  end

  def lecturer_attendance_and_punctuality
    lecturers_hash_attendance = {}
    lecturers_hash_punctuality = {}
    lecturers_hash = {}

    lecturers.each do |lecturer|
      lecturers_hash_attendance[lecturer] = []
      lecturers_hash_punctuality[lecturer] = []
    end

    lectures.select{ |l| l.has_finished? }.each do |lecture|
      lecturers_hash_attendance[lecture.lecturer] << lecture.attendance
      lecturers_hash_punctuality[lecture.lecturer] << lecture.average_minutes_to_class
    end

    lecturers_hash_attendance.each do |k, v|
      lecturers_hash_attendance[k] = (v.sum / v.count).round rescue 100
    end

    lecturers_hash_punctuality.each do |k, v|
      lecturers_hash_punctuality[k] = (v.sum / v.count).round rescue 0
    end

    lecturers_hash_attendance.each do |k, v|
      lecturers_hash[k] = [
        lecturers_hash_attendance[k],
        lecturers_hash_punctuality[k]
      ]
    end

    lecturers_hash
  end

  def attendance_of_student(student)
    classes_total = 0
    classes_attended = 0

    lectures.select { |l|
      l.has_finished? and l.has_student?(student)
    }.each do |lecture|
      student_attended = lecture.attendance_of_student(student)

      classes_total += 100
      classes_attended += 100 if student_attended
    end

    ((classes_attended.to_f / classes_total.to_f) * 100.0).round
  end


  def average_minutes_of_student(student)
    average_minutes = []

    lectures.select { |l|
      l.has_finished? and l.has_student?(student)
    }.each do |lecture|
      average_minutes << lecture.average_minutes_of_student(student)
    end

    (average_minutes.sum.to_f / average_minutes.count.to_f).round rescue 0
  end

  def average_time_at_event
    lectures_in = LectureStudent.where_lecture(self)
    times_arrived_at = lectures_in.select{ |l| l.lecture.end_time < Time.now }.map{ |l| (l.attendance_time.to_s.to_time - l.lecture.start_time).to_f.presence }.select(&:present?)
    (times_arrived_at.sum / times_arrived_at.count.to_f) rescue 0
  end

  def average_minutes_to_class
    (average_time_at_event / 60.0).round rescue 0
  end
end
