class RemoveStudentIdFromLecturerStudent < ActiveRecord::Migration
  def change
    remove_column :lecture_students, :student_id, :integer
  end
end
