class CustomerLocationAlert < ActiveRecord::Base

	self.table_name = "customer_location_alerts"
    self.primary_key = 'id'

	#acts_as_mappable :default_units => :miles,
					#:lat_column_name => :latitude,
                   	#:lng_column_name => :longtitude
	belongs_to :user
	validates :longtitude, :latitude, presence: true
	validate :check_slot_valid

	def describe_id
  	"CustomerLocationAlert ##{id}"
  	end

	def check_slot_valid
		date = DateTime.now
		count_data = CustomerLocationAlert.where("time_expired > '#{date}' and user_id=#{self.user_id.to_i}").count
		
		if count_data >= 10
			self.errors.add(:base,"Too much alert") 
			return false 
		end
		return true
	end

	before_create do
    	self.time_expired = Time.now + 8.hours
  	end
end
