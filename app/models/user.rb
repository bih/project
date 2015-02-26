class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true
  validates :account_type, :presence => true

  validates :mmu_id, :presence => true, :if => Proc.new { |user| user.type == :student }
  validates :course_name, :presence => true, :if => Proc.new { |user| user.type == :student }

  validates_length_of :mmu_id, :is => 8, :if => Proc.new { |user| user.type == :student }
  validates_uniqueness_of :email
  validates_uniqueness_of :mmu_id, :if => Proc.new { |user| user.type == :student }

  has_many :lecture_students
  audited

  # If no account type is provided, default to student.
  before_create do
    account_type = 'student' if account_type.blank?
  end

  before_destroy do
    return false if Lecture.where_user(self).count > 0

    Lecture.where_user(self).destroy_all
    UnitLecturer.where_user(self).destroy_all
  end

  # Validate account type.
  validate do
    errors.add(:account_type, 'can only be admin, lecturer or student') if not [:admin, :lecturer, :student].include?(account_type.to_s.downcase.to_sym)
  end

  def name
    [first_name, last_name].join(' ')
  end

  def make_admin!
    update_attribute(:account_type, 'admin')
  end

  def make_lecturer!
    update_attribute(:account_type, 'lecturer')
  end

  def make_student!
    update_attribute(:account_type, 'student')
  end

  def admin?
    type == :admin
  end

  def admin_or_lecturer?
    [:admin, :lecturer].include?(type)
  end

  def lecturer?
    type == :lecturer
  end

  def student?
    type == :student
  end

  def attendance
    lectures_in = LectureStudent.where_user(self)
    lectures_already_happened = lectures_in.select{ |l| l.lecture.end_time < Time.now }.count
    lectures_already_happened_that_was_attended = lectures_in.select{ |l| l.lecture.end_time < Time.now && l.attendance == true }.count

    if lectures_already_happened > 0
      ((lectures_already_happened_that_was_attended.to_f / lectures_already_happened.to_f) * 100).round(1)
    else
      100.0
    end
  end

  def lectures
    @lectures ||= lecture_students.all.map{ |ls| ls.lecture }
  end

  def lectures_with_attendance
    @lectures_with_attendance ||= lecture_students.all.map{ |ls| [ls, ls.lecture] }   
  end

  def lectures_now
    @lectures_now ||= lectures.select{ |l| l.currently_on? }
  end

  def lectures_in_past
    @lectures_in_past ||= lectures.select{ |l| l.has_started? }
  end

  def lectures_in_future
    @lectures_in_future ||= lectures.reject{ |l| l.has_started? }
  end

  def average_time_at_event
    lectures_in = LectureStudent.where_user(self)
    times_arrived_at = lectures_in.select{ |l| l.lecture.end_time < Time.now }.map{ |l| (l.attendance_time.to_s.to_time - l.lecture.start_time).to_f.presence }.select(&:present?)
    (times_arrived_at.sum / times_arrived_at.count.to_f) rescue 0.0
  end

  def type
    account_type.to_sym rescue :student
  end

  def self.options_for_types
    [["Student", :student], ["Lecturer", :lecturer], ["Administrator", :admin]]
  end

  def self.where_type(type)
    where(account_type: type.downcase.to_s)
  end

  def self.for_form
    all.map{ |u| [u.name, u.id] }
  end

  def self.find_by_mmu_id(mmu_id)
    where(mmu_id: mmu_id).first
  end

  def leaders_of
    UnitLecturer.where_user(self).all_from_units
  end

  def lectures_taught_in(unit)
    unit.lectures.select{ |l| l.user_id == id }
  end

  def attendance_as_gchart
    attendance = {}
    attendance_names = []
    colours = ["535aac", "825959", "843e01", "0a7061", "17334a", "6320df", "f40b59"].first(7).join(',')

    (1..52).each{ |number| attendance[number] = {} }

    lectures_with_attendance.each do |a, lecture|
      attendance[lecture.start_time.strftime('%W').to_i][lecture.unit.unit_name] ||= []
      attendance[lecture.start_time.strftime('%W').to_i][lecture.unit.unit_name].push(a.attended?)
    end
    
    attendance = attendance.select{ |week, a| a.count > 0 }
    final_attendance = attendance.map do |week, units|
      units.sort.map do |unit, attended|
        did_attend = attended.select{ |a| a == true }.count.to_f
        altogether = attended.count.to_f

        attendance_names.push(unit) unless attendance_names.include?(unit)

        ((did_attend / altogether) * 100.0).round(1) rescue 100.0
      end
    end

    if attendance.count > 1
      Gchart.line(:data => final_attendance, :line_colors => colours, :min_value => 0, :max_value => 100, :title => "Attendance for #{name} by week and units", :size => "550x200", :legend => attendance_names, :labels => attendance.keys.map{ |k| "Week #{k}" })
    else
      nil
    end
  end

protected

  def password_required?
    new_record? ? true : false
  end
end
