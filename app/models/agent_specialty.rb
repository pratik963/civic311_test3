class AgentSpecialty < ActiveRecord::Base

  self.table_name = "agent_specialties"
  self.primary_key = 'id'

  belongs_to :agent, :inverse_of => :agent_specialties
  belongs_to :specialty, :inverse_of => :agent_specialties

  def describe_id
  	"AgentSpecialty ##{id}"
  end
end