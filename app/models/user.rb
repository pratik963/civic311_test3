class User < ActiveRecord::Base
  self.table_name = "users"
  self.primary_key = 'id'

  has_one :agent, :dependent => :destroy, :inverse_of => :user
  has_one :customer, :dependent => :destroy, :inverse_of => :user
  has_many :issues, :inverse_of => :user
  has_many :suggestions, :inverse_of => :user
  has_many :customer_devices, :inverse_of => :user
  has_many :customer_location_alerts, :inverse_of => :user
  has_many :agent_change_info, :inverse_of => :user

  accepts_nested_attributes_for :customer, :agent

  #rails_admin do
    #configure :customer do
      #visible(false)
    #end

    #configure :agent do
      #visible(false)
    #end
  #end


  def name
    "#{email}"
  end

  def role
    if self.customer.present?
      return I18n.t 'customer'
    elsif self.agent.present?
      return I18n.t 'agent'
    else
      return 'admin'
    end
  end

  def valid_device_token(device_token, device_type)
	device_verified=false;
	#return device_verified;	
	if(device_type && device_type && !device_type.blank? && !device_token.blank?)		
		customer_devices = self.customer_devices.where(:device_type => device_type, :device_token =>device_token)
		if customer_devices.count > 0			
			device_verified=true;
		else			
			customer = self.customer;
			#return customer.id;	
			customer.update_attributes(:phone_verified => false) 	
		    device_verified =false;
		end		
	end
	return device_verified;
  end

  def generate_endpoint_arn(token, device_type)
    sns = Aws::SNS::Client.new
    begin
      if self.role =='agent'
        if device_type == "Android"
        endpoint = sns.create_platform_endpoint(
          platform_application_arn:'arn:aws:sns:us-west-2:126524593432:app/GCM/Agento_Floortime',
            token:token)
        else
          endpoint = sns.create_platform_endpoint(
            platform_application_arn:'arn:aws:sns:us-west-2:126524593432:app/APNS_SANDBOX/Agento_Floortime_iOS',
            token: token)
        end
      elsif self.role =='customer'
        if device_type == "Android"
        endpoint = sns.create_platform_endpoint(
          platform_application_arn:'arn:aws:sns:us-west-2:126524593432:app/GCM/Agento_Customer',
            token:token)
        else
          endpoint = sns.create_platform_endpoint(
            platform_application_arn:'arn:aws:sns:us-west-2:126524593432:app/APNS_SANDBOX/Agento_Customer_iOS',
            token: token)
        end
      else
        p "unknown"
      end
        
      
    rescue Exception => e
        p e
        return false
    end
    return endpoint.endpoint_arn
  end

  def add_device(endpoint_arn, device_type, device_token)
    begin
        customer_device = CustomerDevice.find_or_initialize_by(endpoint_arn: endpoint_arn)
        customer_device.endpoint_arn = endpoint_arn
        customer_device.device_type = device_type
        customer_device.device_token = device_token
        customer_device.user_id = self.id
        customer_device.save
        return true
    rescue Exception => e

      return false
    end
  end
  
end
