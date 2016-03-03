class PaymentTransaction < ActiveRecord::Base

  self.table_name = "payment_transactions"
  self.primary_key = 'id'

  belongs_to :agent, :inverse_of => :payment_transactions
  belongs_to :promotion_code, :inverse_of => :payment_transactions, foreign_key: "promotion_id"

  def describe_id
  	"PaymentTransaction ##{id}"
  end
end