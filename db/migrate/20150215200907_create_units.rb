class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :unit_name
      t.string :unit_year

      t.timestamps null: false
    end
  end
end
