class AddUnitCodeToUnits < ActiveRecord::Migration
  def change
    add_column :units, :unit_code, :string
  end
end
