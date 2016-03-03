class InvestmentType < ActiveRecord::Base

  self.table_name = "investment_types"
  self.primary_key = 'id'

  has_many :investing_wishlist_types, :inverse_of => :investment_type

  # Get All Investment Type
  def self.get_all_investment_types
    Hash[*InvestmentType.order(:name).pluck(:id, :name).flatten]
  end
  
end