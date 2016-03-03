class Connection < ActiveRecord::Base
  
  self.table_name = "connections"
  self.primary_key = 'id'

  belongs_to :agent, foreign_key: "agent_id"
  belongs_to :customer, foreign_key: "customer_id"
  belongs_to :sharing, foreign_key: "sharing_id"
  
  def describe_id
  	"Connection ##{id}"
  end
end
