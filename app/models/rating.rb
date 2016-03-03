class Rating < ActiveRecord::Base
  
  self.table_name = "ratings"
  self.primary_key = 'id'

  belongs_to :agent, :inverse_of => :ratings
  belongs_to :customer, :inverse_of => :ratings
  belongs_to :rating_question, :inverse_of => :ratings
  
  def describe_id
  	"Rating ##{id}"
  end
end
