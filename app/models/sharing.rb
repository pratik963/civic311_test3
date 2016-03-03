class Sharing < ActiveRecord::Base

  self.table_name = "sharings"
  self.primary_key = 'id'

  has_one :acceptance, :inverse_of => :sharing
  has_many :connections, :dependent => :delete_all, foreign_key: "sharing_id"
  belongs_to :wishlist, :inverse_of => :sharings, foreign_key: "wishlist_id"
  belongs_to :request_showing, :foreign_key => "request_id"

  def describe_id
  	"Sharing ##{id}"
  end
  
end
