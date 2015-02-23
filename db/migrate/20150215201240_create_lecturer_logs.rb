class CreateLecturerLogs < ActiveRecord::Migration
  def change
    create_table :lecturer_logs do |t|
      t.integer :user_id
      t.string :action_text

      t.timestamps null: false
    end
  end
end
