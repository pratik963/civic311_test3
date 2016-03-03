class AgentChangeInfo < ActiveRecord::Base

	self.table_name = "agent_change_infos"
    self.primary_key = 'id'

	PENDING = "pending"
	APPROVED = "approved"
	CHANGE_COMPANY_NAME = "change_company_name"
	CHANGE_PROFILE = "change_profile"
	REJECT = "reject"
 	belongs_to :user
 	#validate :first_name_new, :last_name_new, presence: true
 	after_update :update_edit_state

 	def describe_id
  	"AgentChangeInfo ##{id}"
  	end
 	
 	def update_edit_state
 		if status_changed?
 			agent = self.user.agent
 			action = self.action
 			status = self.status
 			p action
 			p status
 			if action == CHANGE_PROFILE
 				if status == REJECT
	 				begin
	 					agent.update!(first_name: self.first_name_old, last_name: last_name_old,edit_profile_state: REJECT)
	 					UserMailer.delay.send_email_notification(agent, CHANGE_PROFILE, REJECT)
	 					agent.push_notification_apply_change(REJECT,self);
	 				rescue Exception => e
						p e 					
	 				end
	 			elsif status == APPROVED
	 				begin
	 					agent.update!(edit_profile_state: APPROVED,:first_name => self.first_name_new,:last_name => self.last_name_new)
	 					UserMailer.delay.send_email_notification(agent, CHANGE_PROFILE, APPROVED)
	 					agent.push_notification_apply_change(APPROVED,self)
		 			rescue Exception => e
		 				p e
		 			end
		 		else
		 			return
	 			end
	 		elsif action == CHANGE_COMPANY_NAME
	 			if status == REJECT
	 				begin
	 					agent.update!(company_name: self.company_name_old,edit_company_name_state: REJECT)
	 					UserMailer.delay.send_email_notification(agent, CHANGE_COMPANY_NAME, REJECT)
	 					agent.push_notification_apply_change_company(REJECT,self)
	 				rescue Exception => e
	 					p e
	 				end
	 			elsif status == APPROVED
	 				begin
	 					agent.update!(company_name: self.company_name_new,edit_company_name_state: APPROVED)
	 					UserMailer.delay.send_email_notification(agent, CHANGE_COMPANY_NAME, APPROVED)
	 					agent.push_notification_apply_change_company(APPROVED,self)
	 				rescue Exception => e
	 					p e
	 				end
	 			end
 			end
 		end
 	end
end
