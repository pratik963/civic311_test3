class SellingWishlist < ActiveRecord::Base
  
  self.table_name = "selling_wishlists"
  self.primary_key = 'id'

  has_one :wishlist, foreign_key: "id"
  belongs_to :property_type, :inverse_of => :selling_wishlists

  def show_details
    {
      id:                  self.id,
      name:                self.name,
      property_type_id:    self.property_type_id,
      listing_status:      self.listing_status,
      relationship:        self.relationship,
      planning_to_sell:    self.planning_to_sell,
      resident_status:     self.resident_status,
      beds_number:         self.beds_number,
      baths_number:        self.baths_number,
      square_footage:      self.square_footage,
      built_year:          self.built_year,
      lot_size:            self.lot_size,
      timeframe:           self.timeframe,
      interested_in:       self.interested_in
    }
  end
  
end