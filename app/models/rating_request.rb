class RatingRequest < ActiveRecord::Base
  
  self.table_name = "rating_requests"
  self.primary_key = 'id'

  belongs_to :agent, :inverse_of => :rating_request

end
