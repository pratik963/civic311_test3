class InvestingWishlistType < ActiveRecord::Base

  self.table_name = "investing_wishlist_types"
  self.primary_key = 'id'

  belongs_to :investing_wishlist, :inverse_of => :investing_wishlist_types
  belongs_to :investment_type, :inverse_of => :investing_wishlist_types

  def describe_id
  	"InvestingWishlistType ##{id}"
  end
end