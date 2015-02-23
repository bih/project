class DestroyLecturerLogTable < ActiveRecord::Migration
  def change
    drop_table :lecturer_logs
  end
end
