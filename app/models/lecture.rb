class Lecture < ActiveRecord::Base
  belongs_to :unit # unit that the lecture is a a part of
  belongs_to :user # lecturer
  has_many :lecture_students # students of the lecture

  validates_uniqueness_of :lecture_name, :scope => [:user_id, :unit_id, :start_time, :end_time]

  validates :lecture_name, :presence => true
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
    errors.add(:end_time, "cannot be before or equal to the start time") if (end_time || 1) <= (start_time || 1)
  end

  before_destroy do
    LectureStudent.where_lecture(id).destroy_all
  end

  def self.where_unit(unit_id)
    where(unit_id: unit_id)
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

  def self.during_week(date = nil)
    beginning_of_week = (date || Date.today).at_beginning_of_week.to_time
    end_of_week = (date || Date.today).at_end_of_week.to_time

    where("start_time > ?", beginning_of_week).where("end_time < ?", end_of_week)
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
    ((attendance_actual.to_f / attendance_expected.to_f) * 100.0).floor rescue 0
  end

  def average_time_at_event
    lectures_in = LectureStudent.where_lecture(self)
    times_arrived_at = lectures_in.select{ |l| l.lecture.end_time < Time.now }.map{ |l| (l.attendance_time.to_s.to_time - l.lecture.start_time).to_f.presence }.select(&:present?)
    (times_arrived_at.sum / times_arrived_at.count.to_f) rescue 0.0
  end
end
