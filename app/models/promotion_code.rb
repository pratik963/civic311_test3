class PromotionCode < ActiveRecord::Base
  
  self.table_name = "promotion_codes"
  self.primary_key = 'id'

  validates :promotion_code, uniqueness: true

  has_many :payment_transactions, :inverse_of => :promotion_code, :foreign_key => "promotion_id"

end	