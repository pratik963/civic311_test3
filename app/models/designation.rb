class Designation < ActiveRecord::Base

  self.table_name = "designations"
  self.primary_key = 'id'

  has_many :agent_designations, :inverse_of => :designation

  def name
    designation
  end

  # Get All Designations
  def self.get_all_designations
    Hash[*Designation.pluck(:id, :designation).flatten]
  end

  # Get Agent's designations
  def self.get_agent_designations(agent)
    Hash[*AgentDesignation.where(agent_id: agent.id).joins(:designation).pluck(:designation_id, :designation).flatten]
  end

  #rails_admin do 

    #configure :agent_designations do
      #visible(false)
    #end
    
  #end
end