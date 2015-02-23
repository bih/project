class CreateLectures < ActiveRecord::Migration
  def change
    create_table :lectures do |t|
      t.integer :unit_id
      t.string :lecture_name
      t.integer :user_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :attendance_expected
      t.integer :attendance_actual

      t.timestamps null: false
    end
  end
end
