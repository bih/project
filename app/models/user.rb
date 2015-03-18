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

  def part_of_unit?(units)
    units = [units] unless units.is_a?(Array)

    lecture_students.select do |ls|
      units.include?(ls.lecture.unit)
    end.count > 0
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

  def lecturer_attendance
    lectures_taught = Lecture.where_user(self)

    attendance = lectures_taught.select{ |l| l.end_time < Time.now }.map do |l|
      l.attendance.to_i
    end

    if attendance.count > 0
      attendance.sum.to_f / attendance.count.to_f
    else
      100.0
    end
  end

  def watchlist?
    attendance <= 75 or average_minutes_to_class >= 15
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

  def lectured_in_past
    @lectured_in_past ||= Lecture.where_user(id).all.select{ |l| l.has_started? }
  end

  def lecturing_in_future
    @lecturing_in_future ||= Lecture.where_user(id).all.reject{ |l| l.has_started? }
  end

  def average_time_at_event
    times_arrived_at = lecture_students.select{ |l| l.lecture.end_time < Time.now }.map{ |l| (l.attendance_time - l.lecture.start_time).to_f.presence rescue nil }.select(&:present?)
    (times_arrived_at.sum / times_arrived_at.count.to_f) rescue 0.0
  end

  def average_minutes_to_class
    (average_time_at_event / 60.0).round rescue 0
  end

  def lecturer_average_minutes_to_class
    mins = Lecture.where_user(id).map do |l|
      l.average_minutes_to_class
    end

    (mins.sum / mins.count) rescue 0
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

  def self.for_form_and_part_of_unit(units)
    units = [units] unless units.is_a?(Array)

    all.select do |u|
      units.map do |unit|
        true if u.teaches_in_or_leader_of?(unit)
      end.flatten.include?(true)
    end.map{ |u| [u.name, u.id] }
  end

  def self.find_by_mmu_id(mmu_id)
    where(mmu_id: mmu_id).first
  end

  def teaches_in_or_leaders_of
    a = UnitLecturer.where_user(self).all_from_units
    b = Lecture.where_user(self).all.map{ |u| u.unit }

    (a + b).flatten.uniq
  end

  def leaders_of
    UnitLecturer.where_user(self).all_from_units
  end

  def is_unit_leader?
    leaders_of.count > 0
  end

  def lectures_taught_in(unit)
    unit.lectures.select{ |l| l.user_id == id }
  end

  def teaches_in_or_leader_of?(unit)
    lectures_taught_in(unit).count > 0 or leaders_of.include?(unit)
  end

  def attendance_by_lecturer
    lecturers = {}

    lecture_students.each do |ls|
      key = "#{ls.lecture.lecturer.id}:#{ls.lecture.lecturer.name}:#{ls.lecture.unit.id}:#{ls.lecture.unit.unit_name}"

      if lecturers.include?(key)
        lecturers[key] << ls.lecture
      else
        lecturers[key] = [ls.lecture]
      end
    end

    lecturers
  end

  def attendance_by_day
    days = {}
    (1..5).each{ |n| days[Date::DAYNAMES[n]] = [] }

    lecture_students.each do |ls|
      begin
        days[ls.lecture.start_time.strftime("%A")] << ls.attended?
      rescue
      end
    end

    days.each do |day, attendances|
      attended = attendances.select{ |d| d == true }.count
      total = attendances.count

      days[day] = ((attended.to_f / total.to_f) * 100.0).round rescue 100
    end

    days
  end

  def attendance_by_day_as_gchart
    attendance = attendance_by_day

    if attendance.count > 1
      Gchart.line(:data => attendance.values, :min_value => 0, :max_value => 100, :title => "Attendance for #{name} by day of the week", :size => "550x200", :labels => attendance.keys)
    else
      nil
    end
  end

  def attendance_as_gchart
    attendance = {}
    attendance_names = []
    colours = ["535aac", "825959", "843e01", "0a7061", "17334a", "6320df", "f40b59"].first(7).join(',')

    lectures_with_attendance.each do |a, lecture|
      if attendance.include?(lecture.unit.unit_name)
        attendance[lecture.unit.unit_name][lecture.start_time.strftime('%W').to_i].push(a.attended?)
      else
        attendance[lecture.unit.unit_name] ||= {}
        (1..52).each{ |number| attendance[lecture.unit.unit_name][number] = [] }
      end
    end

    attendance.each do |unit, weeks|
      attendance_names.push(unit) unless attendance_names.include?(unit)
      attendance[unit] = weeks.select{ |week, attended| attended.count > 0 }
    end

    max_size = attendance.first.count
    all_weeks = attendance.values.first.keys
    attendance.each do |unit, weeks|
      max_size = weeks.count if weeks.count > max_size
      all_weeks << weeks.keys
    end

    all_weeks = all_weeks.flatten.uniq.sort

    attendance.each do |unit, weeks|
      all_weeks.each do |week|
        if not attendance[unit].keys.include?(week)
          attendance[unit][week] = {}
        end
      end
    end

    final_attendance = attendance.map do |unit, weeks|
      weeks.sort.map do |week, attended|
        did_attend = attended.select{ |a| a == true }.count.to_f
        altogether = attended.count.to_f

        ((did_attend / altogether) * 100.0).round rescue 100
      end
    end

    if final_attendance.count > 1
      Gchart.line(:data => final_attendance, :line_colors => colours, :min_value => 0, :max_value => 100, :title => "Attendance for #{name} by week and units", :size => "550x200", :legend => attendance_names, :labels => all_weeks.map{ |k| "Week #{k}" })
    else
      nil
    end
  end

protected

  def password_required?
    new_record? ? true : false
  end
end
