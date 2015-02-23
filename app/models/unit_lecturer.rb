class UnitLecturer < ActiveRecord::Base
  belongs_to :user
  belongs_to :unit
  
  audited :associated_with => :user
  audited :associated_with => :unit

  validates_uniqueness_of :user, :scope => [:unit]
  
  def self.where_unit(unit_id)
    where(unit_id: unit_id)
  end

  def self.where_user(user_id)
    where(user_id: user_id)
  end

  def self.all_from_units
    all.map{ |ul| ul.unit }
  end
end
