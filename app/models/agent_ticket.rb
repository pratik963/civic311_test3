class AgentTicket < ActiveRecord::Base

  self.table_name = "agent_tickets"
  self.primary_key = 'id'	

  validates :tick_type, presence: true
  validates :name, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}
  validates :phone_number, presence: true
  validates :content, presence: true
end