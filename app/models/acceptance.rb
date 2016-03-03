class Acceptance < ActiveRecord::Base
  
  self.table_name = "acceptances"
  self.primary_key = 'id'

  belongs_to :sharing, :inverse_of => :acceptance
  belongs_to :agent, :inverse_of => :acceptances

  def describe_id
  	"Acceptance ##{id}"
  end

end