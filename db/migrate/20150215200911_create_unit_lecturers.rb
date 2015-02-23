class CreateUnitLecturers < ActiveRecord::Migration
  def change
    create_table :unit_lecturers do |t|
      t.integer :user_id
      t.integer :unit_id

      t.timestamps null: false
    end
  end
end
