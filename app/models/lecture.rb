class Lecture < ActiveRecord::Base
  belongs_to :unit # unit that the lecture is a a part of
  belongs_to :user # lecturer
  has_many :lecture_students # students of the lecture

  validates_uniqueness_of :lecture_name, :scope => [:user_id, :unit_id, :start_time, :end_time]

  validates :lecture_name, :presence => true
  validates :lecture_type, :presence => true
  validates :lecture_room, :presence => true
  validates :unit_id, :presence => true
  validates :user_id, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true

  audited :associated_with => :unit
  audited :associated_with => :user

  before_create do
    self.attendance_expected = 0
    self.attendance_actual = 0
  end

  validate :avoid_ending_before_starting
  def avoid_ending_before_starting
    errors.add(:end_time, "cannot be before or equal to the start time") if end_time.presence <= start_time.presence
  rescue
    errors.add(:start_time, "or end time cannot be empty")    
  end

  before_destroy do
    LectureStudent.where_lecture(id).destroy_all
  end

  def self.where_unit(unit_id)
    where(unit_id: unit_id)
  end

  def self.on_day(day)
    start = day.beginning_of_day
    finish = (day + 1.day).beginning_of_day

    where("start_time > ?", start).where("start_time < ?", finish)
  rescue
    []
  end

  def self.where_user(user_id)
    where(user_id: user_id)
  end

  def self.where_finished
    where("end_time < ?", Time.now)
  end

  def self.this_week
    during_week
  end

  def self.last_week
    during_week(Date.today - 1.week)
  end

  def self.calculate_attendance_for_student(array, student)
    attended = array.select{ |f| f.has_student_attended?(student) }.count
    total = array.select{ |f| f.has_student?(student) }.count

    ((attended.to_f / total.to_f) * 100.0).round
  end

  def self.calculate_punctuality_for_student(array)
    (array.sum / array.count).round
  end

  def self.during_week(date = nil)
    beginning_of_week = (date || Date.today).at_beginning_of_week.to_time
    end_of_week = (date || Date.today).at_end_of_week.to_time

    where("start_time > ?", beginning_of_week).where("start_time < ?", end_of_week)
  end

  def self.for_form
    all.map{ |l| [l.lecture_name, l.id] }
  end

  def self.types_for_form
    [
      ["Lecture", :lecture],
      ["Lab", :lab],
      ["Tutorial", :tutorial],
      ["Seminar", :seminar]
    ]
  end

  def lecturer
    user
  end

  def has_started?
    Time.now > start_time
  end

  def has_closed?
    Time.now > end_time
  end

  def has_finished?
    has_closed?
  end

  def currently_on?
    has_started? and not has_closed?
  end

  def is_full?
    attendance_actual >= attendance_expected
  end

  def check_in_student!(user)
    return false unless user.student?
    
    attendance_item = lecture_students.where_user(user.id).first
    return false unless attendance_item.attendance.presence.nil? or attendance_item.attendance_time.presence.nil?

    attendance_item.update_attributes({
        attendance: true,
        attendance_time: Time.now
      })

    update_attribute(:attendance_actual, attendance_actual + 1)
    true
  rescue
    false
  end

  def has_student?(student)
    lecture_students.where_user(student.id).any?
  end

  def has_student_attended?(student)
    lecture_students.where_user(student.id).select{ |ls| ls.attended? }.any?
  end

  def other_lectures
    (unit.lectures.all - [self])
  end

  def other_lectures_for_form
    (unit.lectures.all - [self]).select{ |l| l.attendance_expected > 0 && (l.students - self.students).count > 0 }.map{ |l| ["#{l.lecture_name} (#{l.attendance_expected} students)", l.id] }
  end

  def students
    lecture_students.map{ |a| a.user }
  end

  def students_with_attendance
    lecture_students.map{ |a| [a, a.user] }
  end

  def duration
    hours = ((end_time - start_time) / 1.hour).round
    word = "hour".pluralize(hours)
    "#{hours} #{word}"
  end

  def attendance
    ((attendance_actual.to_f / attendance_expected.to_f) * 100.0).floor rescue 100.0
  end

  def attendance_of_student(student)
    students_with_attendance.select{ |a| a.last == student }.map{ |a| a.first.attended? }.first
  end

  def average_minutes_of_student(student)
    students_with_attendance.select{ |a| a.last == student }.map{ |a| a.first.minutes_late }.first
  end

  def average_time_at_event
    return 0.0 if lecture_students.count == 0

    times_arrived_at = lecture_students.select{ |l| l.lecture.has_finished? }.map{ |l| l.minutes_late_or_nil }.select(&:present?)
    return 0.0 if times_arrived_at.count == 0

    (times_arrived_at.sum.to_f / times_arrived_at.count.to_f) rescue 0.0
  end

  def average_minutes_to_class
    (average_time_at_event / 60.0).round
  end
end
