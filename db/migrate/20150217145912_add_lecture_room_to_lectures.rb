class AddLectureRoomToLectures < ActiveRecord::Migration
  def change
    add_column :lectures, :lecture_room, :string
  end
end
