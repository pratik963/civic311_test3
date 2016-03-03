class CustomerDevice < ActiveRecord::Base

	self.table_name = "customer_devices"
    self.primary_key = 'id'

	belongs_to :user

	def describe_id
  	"CustomerDevice ##{id}"
  	end

	def enpoint_arn_enable?(sns)
		begin
			info = sns.get_endpoint_attributes(endpoint_arn: self.endpoint_arn)
			return info.attributes["Enabled"] == "true" ? true : false
		rescue Exception => e
			p "==========="
			p e
			return false
		end
	end

	def endable_endpoint_arn(sns)
		begin
			sns.set_endpoint_attributes(endpoint_arn: self.endpoint_arn,attributes: {Enabled: "true"})
			return true
		rescue Exception => e
			return false
		end
	end

	def disable_endpoint_arn(sns)
		begin
			sns.set_endpoint_attributes(endpoint_arn: self.endpoint_arn,attributes: {Enabled: "false"})
			return true
		rescue Exception => e
			return false
		end
	end

	def remove_endpoint_arn(sns)
		begin
			endpoint_arn = self.endpoint_arn
			self.destroy
			sns.delete_endpoint(endpoint_arn: endpoint_arn)
			return true
		rescue Exception => e
			p "======="
			p e
			return false
		end
	end

	def push_notification(message_text)
	    sns = Aws::SNS::Client.new
	    
	    enable = self.enpoint_arn_enable?(sns)
	    if enable
	      if self.device_type == "Android"
	        begin
	        	p "================publish android"
	        	gcm_message = {data: {message: message_text}}
	   			message = {"GCM"=> gcm_message.to_json}.to_json
				resp = sns.publish({
				target_arn: self.endpoint_arn,
				message_structure: "json",
				message: message,})
	        rescue Exception => e
	          p e
	        end
	      elsif self.device_type == "iOS"
	        iphone_notification = {aps: {alert: message_text, sound: "default", badge: 1, extra:  {a: 1, b: 2}}}
	        sns_message = {
	          default: "Hi there",
	          APNS_SANDBOX: iphone_notification.to_json,
	          APNS: iphone_notification.to_json
	        }
	        begin
	          resp = sns.publish({
	          target_arn: self.endpoint_arn,
	          message: sns_message.to_json,
	          message_structure:"json"
	          })
	          rescue Exception => e
	            p e
	        end
	      else
	        p "=====Unknown device========"
	      end
	    else
	      self.remove_endpoint_arn(sns)
	    end
  	end




  	def push_notification_all(message_text)
	    sns = Aws::SNS::Client.new
	    
	    enable = self.enpoint_arn_enable?(sns)
	    if enable
	      if self.device_type == "Android"
	        begin
	        	p "================publish android"
	        	gcm_message = {data: message_text}
	   			message = {"GCM"=> gcm_message.to_json}.to_json
				resp = sns.publish({
				target_arn: self.endpoint_arn,
				message_structure: "json",
				message: message,})
	        rescue Exception => e
	          p e
	        end
	      elsif self.device_type == "iOS"
	        iphone_notification = message_text
	        sns_message = {
	          default: "Hi there",
	          APNS_SANDBOX: iphone_notification.to_json,
	          APNS: iphone_notification.to_json
	        }
	        begin
	          resp = sns.publish({
	          target_arn: self.endpoint_arn,
	          message: sns_message.to_json,
	          message_structure:"json"
	          })
	          rescue Exception => e
	            p e
	        end
	      else
	        p "=====Unknown device========"
	      end
	    else
	      self.remove_endpoint_arn(sns)
	    end
  	end


  	def push_notification_change_first_last_name(status,agent_changeinfo)
	    iphone_notification = {}
  		if status == "approved"
  			iphone_notification[:aps] = {:alert=>{:title =>"Update basic profile",:body => "Profile was approved"}}
  			iphone_notification[:type] = "change_basic_info"
  			iphone_notification[:information] ={
  				result: "APPROVED",
  				first_name: agent_changeinfo.first_name_new,
  				last_name: agent_changeinfo.last_name_new
  			}
  		else
  			iphone_notification[:aps] = {:alert=>{:title =>"Update basic profile",:body => "Profile was rejected"}}
  			iphone_notification[:type] = "change_basic_info"
  			iphone_notification[:information] ={
  				result: "REJECT",
  				first_name: agent_changeinfo.first_name_old,
  				last_name: agent_changeinfo.last_name_old
  			}

  		end
  		push_notification_all(iphone_notification)
  	end

  	def push_notification_agent_online(agent)
	    iphone_notification = {}
		iphone_notification[:aps] = {:alert=>{:title =>"Agent is online",:body => "Join to get new agents"}}
  		iphone_notification[:type] = "location_agent_online_alert"
  		iphone_notification[:information] ={
  			latitude: agent.latitude,
  			longitude: agent.longitude
  		}

  		push_notification_all(iphone_notification)
  	end


  	def push_notification_change_company_name(status,agent_changeinfo)
	    iphone_notification = {}
  		if status == "approved"
  			iphone_notification[:aps] = {:alert=>{:title =>"Update company name",:body => "Update company name was approved"}}
  			iphone_notification[:type] = "change_company_name"
  			iphone_notification[:information] ={
  				result: "APPROVED",
  				old_company_name: agent_changeinfo.company_name_old,
  				last_company_name: agent_changeinfo.company_name_new
  			}
  		else
  			iphone_notification[:aps] = {:alert=>{:title =>"Update company name",:body => "Update company name was rejected"}}
  			iphone_notification[:type] = "change_company_name"
  			iphone_notification[:information] ={
  				result: "REJECT",
  				old_company_name: agent_changeinfo.company_name_old,
  				last_company_name: agent_changeinfo.company_name_new
  			}

  		end
  		push_notification_all(iphone_notification)
  	end

    def push_notification_change_license(status,agent)
      iphone_notification = {}
      if status == "approved"
        iphone_notification[:aps] = {:alert=>{:title =>"License Info",:body => "License Info was approved"}}
        iphone_notification[:type] = "change_license_info"
        iphone_notification[:information] ={
          result: "APPROVED",
          license_number: agent.license_number,
          state_license_issue: agent.license_state_issued,
          date_license_issue: agent.license_issued_date
        }
      else
        iphone_notification[:aps] = {:alert=>{:title =>"License Info",:body => "License Info was rejected"}}
        iphone_notification[:type] = "change_license_info"
        iphone_notification[:information] ={
          result: "REJECT",
          license_number: agent.license_number,
          state_license_issue: agent.license_state_issued,
          date_license_issue: agent.license_issued_date
        }

      end
      push_notification_all(iphone_notification)
    end

    def push_notification_background(type,agent,customer,sharing)
      iphone_notification = {}
      if type == "share_wishlist"
        iphone_notification[:aps] = {:alert=>{:title =>"Received a Share Wishlist ",:body => "From Customer: #{customer.name}"}}
        iphone_notification[:type] = "share_wishlist"
        
      elsif type == "showing_request"
        iphone_notification[:aps] = {:alert=>{:title =>"Received a Showing Request ",:body => "From Customer: #{customer.name}"}}
        iphone_notification[:type] = "showing_request"
      elsif type == "showing_request_plus"
        iphone_notification[:aps] = {:alert=>{:title =>"Received a Showing Request Plus ",:body => "From Customer: #{customer.name}"}}
        iphone_notification[:type] = "showing_request_plus"
      elsif type == "customer_picked_you"
        iphone_notification[:aps] = {:alert=>{:title =>"Customer has picked you ",:body => "From Customer: #{customer.name}"}}
        iphone_notification[:type] = "customer_picked_you"

      end
      iphone_notification[:agent_id] = agent.id
      iphone_notification[:sharing_id] = sharing.id
      push_notification_all(iphone_notification)

    end


end
