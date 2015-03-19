class LectureStudent < ActiveRecord::Base
  belongs_to :lecture
  belongs_to :user

  audited :associated_with => :lecture
  audited :associated_with => :user

  validates_uniqueness_of :user_id, :scope => [:lecture_id]
  validates :user_id, :presence => true
  validates :lecture_id, :presence => true

  validate :make_sure_user_is_student
  def make_sure_user_is_student
    errors.add(:user_id, "cannot be found or is not a student") if User.where_type(:student).find(user_id).nil?
  end

  before_create do
    self.attendance = nil
    self.attendance_time = nil
    self.attendance_seconds = -1

    self.lecture.update_attribute(:attendance_expected, self.lecture.attendance_expected + 1)
  end

  before_save do
    self.attendance_seconds = (self.attendance_time - self.lecture.start_time).to_i if self.attendance_time_changed?
  end

  before_destroy do
    self.lecture.update_attribute(:attendance_expected, self.lecture.attendance_expected - 1)
  end

  def self.where_lecture(lecture_id)
    where(lecture_id: lecture_id)
  end

  def self.where_user(user_id)
    where(user_id: user_id)
  end

  def self.where_finished
    all.map{ |ls| ls }
  end

  def class_started?
    Time.now > lecture.start_time
  end

  def class_over?
    Time.now > lecture.end_time
  end

  def seconds_late
    res = attendance_seconds
    res = 0 if res.to_i <= 0
    res
  end

  def minutes_late
    (seconds_late / 60.0).round
  end

  def minutes_late_or_nil
    (seconds_late / 60.0).round
  end

  def attended?
    if Time.now > lecture.start_time and attendance == true
      return true
    else
      return false
    end
  end
end
