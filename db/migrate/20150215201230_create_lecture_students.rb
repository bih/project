class CreateLectureStudents < ActiveRecord::Migration
  def change
    create_table :lecture_students do |t|
      t.integer :lecture_id
      t.integer :user_id
      t.string :entry_status
      t.boolean :attendance
      t.datetime :attendance_time

      t.timestamps null: false
    end
  end
end
