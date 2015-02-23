class AddAttendanceSecondsToLectureStudent < ActiveRecord::Migration
  def change
    add_column :lecture_students, :attendance_seconds, :integer
  end
end
