class AddLectureTypeToLecture < ActiveRecord::Migration
  def change
    add_column :lectures, :lecture_type, :string
  end
end
