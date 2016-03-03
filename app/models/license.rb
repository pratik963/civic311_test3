class License < ActiveRecord::Base

  self.table_name = "licenses"
  self.primary_key = 'id'

  validates :license_number, uniqueness: true

  belongs_to :agent, :inverse_of => :licenses
  belongs_to :state, :class_name => "State", :foreign_key => "license_state_issued"

  after_save :update_agent_license

  def describe_id
    "License ##{id}"
  end
  def update_agent_license
  	if self.status == "Actived"

  		agent = self.agent
  		agent.licenses.where("id != ?",self.id).update_all("status ='Deactived'")
  		agent.update_attributes({:license_number => self.license_number, :license_state_issued => self.license_state_issued,:license_issued_date => self.license_issued_date})
      agent.push_notification_change_license("approved")
      UserMailer.delay.send_license_status(agent,"approved")
    elsif self.status =="Deactived"
      agent = self.agent
      agent.push_notification_change_license("rejected")
      UserMailer.delay.send_license_status(agent,"rejected")
    end

  end
end