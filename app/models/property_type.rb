class PropertyType < ActiveRecord::Base

  self.table_name = "property_types"
  self.primary_key = 'id'

  has_many :buying_wishlists, :inverse_of => :property_type
  has_many :selling_wishlists, :inverse_of => :property_type
  has_many :renting_wishlists, :inverse_of => :property_type

  # Get All Property Types
  def self.get_all_property_types
    Hash[*PropertyType.pluck(:id, :name).flatten]
  end
  
end