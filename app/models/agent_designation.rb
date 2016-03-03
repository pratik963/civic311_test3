class AgentDesignation < ActiveRecord::Base
  
  self.table_name = "agent_designations"
  self.primary_key = 'id'

  belongs_to :designation, :inverse_of => :agent_designations
  belongs_to :agent, :inverse_of => :agent_designations

  def describe_id
  	"AgentDesignation ##{id}"
  end
end