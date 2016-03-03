class InvestingWishlist < ActiveRecord::Base

  self.table_name = "investing_wishlists"
  self.primary_key = 'id'

  has_one :wishlist, foreign_key: "id"
  has_many :investing_wishlist_types, :inverse_of => :investing_wishlist

  def show_details
    {
      id: self.id,
      name: self.name,
      timeframe: self.timeframe,
      investment_type_id: InvestingWishlistType.where(investing_wishlist_id: self.id).pluck(:investment_type_id)
    }
  end
  
end