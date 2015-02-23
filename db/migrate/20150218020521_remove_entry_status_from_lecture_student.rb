class RemoveEntryStatusFromLectureStudent < ActiveRecord::Migration
  def change
    remove_column :lecture_students, :entry_status, :string
  end
end
