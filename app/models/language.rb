class Language < ActiveRecord::Base
  
  self.table_name = "languages"
  self.primary_key = 'id'

  has_one :agent_languages, :inverse_of => :language
  has_one :customers, :class_name => "Language", :foreign_key => "id"

  # Get All Languages
  def self.get_all_languages
    Hash[*Language.pluck(:id, :name).flatten]
  end

  # Get Agent's languages
  def self.get_agent_languages(agent)
    Hash[*AgentLanguage.where(agent_id: agent.id).joins(:language).pluck(:language_id, :name).flatten]
  end
  
	# def self.to_csv(options = {})
	  # CSV.generate(options) do |csv|
		# csv << column_names
		# all.each do |language|
		  # csv << language.attributes.values_at(*column_names)
		# end
	  # end
	# end



  #rails_admin do
    #configure :customers do
      #visible(false)
    #end

    #configure :agent_languages do
      #visible(false)
    #end
  #end
end