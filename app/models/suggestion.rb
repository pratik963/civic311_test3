class Suggestion < ActiveRecord::Base

  self.table_name = "suggestions"
  self.primary_key = 'id'

  belongs_to :user
  def describe_id
  	"Suggestion ##{id}"
  end
end
