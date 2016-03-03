class Specialty < ActiveRecord::Base

  self.table_name = "specialties"
  self.primary_key = 'id'

  has_many :agent_specialties, :inverse_of => :specialty

  # Get All Specialties
  def self.get_all_specialties
    Hash[*Specialty.pluck(:id, :name).flatten]
  end

  # Get Agent's specialties
  def self.get_agent_specialties(agent)
    Hash[*AgentSpecialty.where(agent_id: agent.id).joins(:specialty).pluck(:specialty_id, :name).flatten]
  end

  #rails_admin do

    #configure :agent_specialties do
      #visible(false)
    #end
    
  #end
end