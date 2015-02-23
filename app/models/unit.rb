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

  def self.where_leader(user)
    UnitLecturer.where_user(user.id || user.to_i).map{ |ul| ul.unit }
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

  def attendance
    attendance_of_lectures = lectures.map{ |a| a.attendance }
    (attendance_of_lectures.sum / attendance_of_lectures)
  end

  def average_time_at_event
    lectures_in = LectureStudent.where_lecture(self)
    times_arrived_at = lectures_in.select{ |l| l.lecture.end_time < Time.now }.map{ |l| (l.attendance_time.to_s.to_time - l.lecture.start_time).to_f.presence }.select(&:present?)
    (times_arrived_at.sum / times_arrived_at.count.to_f) rescue 0
  end
end
