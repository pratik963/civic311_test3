class RequestShowing < ActiveRecord::Base
    
  self.table_name = "request_showings"
  self.primary_key = 'id'

  has_many :sharings, :foreign_key => "request_id"
  belongs_to :customer

  belongs_to :wishlist, :class_name => "Wishlist", :foreign_key => "attached_wishlist"

  def describe_id
  	"RequestShowing ##{id}"
  end
end
