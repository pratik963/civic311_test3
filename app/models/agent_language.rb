class AgentLanguage < ActiveRecord::Base
  
  self.table_name = "agent_languages"
  self.primary_key = 'id'

  belongs_to :agent, :inverse_of => :agent_languages
  belongs_to :language, :inverse_of => :agent_languages

  def describe_id
  	"AgentLanguage ##{id}"
  end
end