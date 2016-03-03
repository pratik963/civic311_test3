class BuyingWishlist < ActiveRecord::Base

  self.table_name = "buying_wishlists"
  self.primary_key = 'id'

  has_one :wishlist, foreign_key: "id"
  belongs_to :property_type, :inverse_of => :buying_wishlists

  def show_details
    {
      id:                   self.id,
      name:                 self.name,
      price_range_low:      self.price_range_low,
      price_range_high:     self.price_range_high,
      property_type_id:     self.property_type_id,
      beds_number:          self.beds_number,
      baths_number:         self.baths_number,
      square_footage_low:   self.square_footage_low,
      square_footage_high:  self.square_footage_high,
      built_year_low:       self.built_year_low,
      built_year_high:      self.built_year_high,
      lot_size:             self.lot_size,
      listing_type:         self.listing_type.to_s.split(";").join("; "),
      timeframe:            self.timeframe,
      condition:            self.condition,
      gagrage:              self.gagrage,
      pets:                 self.pets,
      view:                 self.view,
      pools:                self.pools
    }
  end

end