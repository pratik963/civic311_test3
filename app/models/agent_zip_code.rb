class AgentZipCode < ActiveRecord::Base
  
  self.table_name = "agent_zip_codes"
  self.primary_key = 'id'

  belongs_to :agent, :inverse_of => :agent_zip_codes

  # Get Agent's zipcodes
  def self.get_agent_zipcodes(agent)
    AgentZipCode.where(agent_id: agent.id).pluck(:zip_code).map{|code| {zip_code: code}}
  end

  def describe_id
  	"AgentZipCode ##{id}"
  end
end