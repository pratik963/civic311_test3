class State < ActiveRecord::Base
  
  self.table_name = "states"
  self.primary_key = 'id'
 # has_many :licenses, :class_name => "State", :foreign_key => "id"

  def name
    state_name
  end

  # Get All States
  def self.get_all_states
    State.pluck(:id, :state_code, :state_name).map{|id, code, name| {id: id, code: code, name: name}}
  end

  #rails_admin do
    #configure :agents do
      #visible(false)
    #end
  #end
end