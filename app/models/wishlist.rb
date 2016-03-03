class Wishlist < ActiveRecord::Base
  
  self.table_name = "wishlists"
  self.primary_key = 'id'

  has_many :request_showings, class_name: "Wishlist", foreign_key: "wishlist_id"
  has_many :sharings, :inverse_of => :wishlist
  belongs_to :customer, :inverse_of => :wishlists
  belongs_to :buying_wishlist, foreign_key: "wishlist_id"
  belongs_to :investing_wishlist, foreign_key: "wishlist_id"
  belongs_to :renting_wishlist, foreign_key: "wishlist_id"
  belongs_to :selling_wishlist, foreign_key: "wishlist_id"
  
  def describe_id
  	"Wishlist ##{id}"
  end
end
