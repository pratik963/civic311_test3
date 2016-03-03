class Agent < ActiveRecord::Base
  
  self.table_name = "agents"
  self.primary_key = 'id'

  #DEFAULT_RADIUS = APP_CONFIG["default_radius"]
  #MAX_RADIUS = APP_CONFIG["max_radius"]
  #MAX_AGENTS_TOTAL = APP_CONFIG["max_agents_total"]

  #PENDING = "pending"
  #APPROVED = "approved"
  #REJECTED = "reject"
  #UNKNOWN = "unknown"
  #CHANGE_COMPANY_NAME = "change_company_name"
  #CHANGE_PROFILE = "change_profile"

  #geocoded_by :address
  #after_validation :geocode

  validates :phone_number, uniqueness: true
  validates :sent_rating, numericality: true,allow_nil: true

  has_many :acceptances, :inverse_of => :agent
  has_many :agent_languages, :inverse_of => :agent
  has_many :agent_specialties, :inverse_of => :agent
  has_many :agent_designations, :inverse_of => :agent
  has_many :agent_zip_codes, :inverse_of => :agent
  has_many :licenses, :inverse_of => :agent
  has_one  :rating_request, :inverse_of => :agent
  has_many :payment_transactions, :inverse_of => :agent
  has_one :ratings, :inverse_of => :agent
 # has_many :connections, :dependent => :delete_all
  belongs_to :user, :inverse_of => :agent
  belongs_to :state, :class_name => "State", :foreign_key => "license_state_issued"

  #has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "150x200^" }, :default_url => ""
  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  
  #rails_admin do
    #configure :connections do
      #visible(false)
    #end
    
    #configure :ratings do
      #visible(false)
    #end
    
    #configure :rating_requests do
      #visible(false)
    #end
    
    #configure :helpings do
      #visible(false)
    #end
  #end

  def name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    end
  end

  def as_json(request)
    avatar = ""
    avatar = request.protocol + request.host_with_port + self.avatar.url if self.avatar.present?
    { 
      email:                self.user.email,
      first_name:           self.first_name,
      last_name:            self.last_name,
      company_name:         self.company_name,
      phone_number:         self.phone_number,
      about:                self.about,
      license_number:       self.license_number,
      license_state_issued: self.license_state_issued,
      license_issued_date:  self.license_issued_date,
      license_url:          self.try(:state).try(:main_page_url),
      status:               self.status,
      website_url:          self.website_url,
      listing_url:          self.listing_url,
      video_url:            self.video_url,
      avatar:               avatar,
      edit_profile_state:   self.edit_profile_state,
      edit_company_name_state: self.edit_company_name_state
     }
  end
  
  def as_json2(request)
    avatar = ""
    avatar = request.protocol + request.host_with_port + self.avatar.url if self.avatar.present?
    agent_change_info = self.user.agent_change_info.where(action: CHANGE_PROFILE, status: [PENDING, APPROVED]).last
    agent_change_company_name = self.user.agent_change_info.where(action: CHANGE_COMPANY_NAME , status: [PENDING, APPROVED]).last
    license = self.licenses.where(status: ["Pending", "Actived"]).last

    { 
      email:                self.user.email,
      first_name:           agent_change_info ? agent_change_info.first_name_new : self.first_name,
      last_name:            agent_change_info ? agent_change_info.last_name_new : self.last_name,
      company_name:         agent_change_company_name ? agent_change_company_name.company_name_new : self.company_name,
      phone_number:         self.phone_number,
      about:                self.about,
      license_number:       license ? license.license_number : self.license_number,
      license_state_issued: license ? license.license_state_issued : self.license_state_issued,
      license_issued_date:  license ? license.license_issued_date : self.license_issued_date,
      license_url:          self.try(:state).try(:main_page_url),
      status:               self.status,
      website_url:          self.website_url,
      listing_url:          self.listing_url,
      video_url:            self.video_url,
      avatar:               avatar,
      edit_profile_state:   self.edit_profile_state,
      edit_company_name_state: self.edit_company_name_state
     }
  end

  def get_rating_information
    ratings = Rating.where(agent_id: self.id)
    numCustomerRates = ratings.distinct.count(:customer_id)
    avgAll = ratings.average('rate').to_f
    avgQuestion = ratings.group('rating_question_id').average('rate').map{|question, rate| {question: question, rate: rate}}
    ratings = ratings.joins(:rating_question).group('category')      
    avgCategory = ratings.average('rate').map{|category, rate| {category: category, rate: rate}}
    numRateCategory = ratings.distinct.count("customer_id").map{|category, num| {category: category, numCustomerRates: num}}
    avgCategory_temp = ratings.average('rate').map{|category, rate| {category: category, numCustomerRates: rate}}
    {numCustomerRates: numCustomerRates, avgAllRates: avgAll, numRateCategory: numRateCategory,avgCategory_temp: avgCategory_temp, avgCategory: avgCategory, avgQuestion: avgQuestion}
  end

  def get_agent_info_history
    agent_change_info = AgentChangeInfo.where(user_id: self.user_id,status: APPROVED,action: CHANGE_COMPANY_NAME).last
    if agent_change_info.blank? || agent_change_info.updated_at < Time.now - 1.months
      self.update_attributes({:edit_company_name_state => PENDING})
      return agent_change_info
    end
    return agent_change_info
  end
  def save_company_name(company_name_new)
      
      agent_change_info = AgentChangeInfo.find_by(user_id: self.user_id,status: PENDING,action: CHANGE_COMPANY_NAME)
      if agent_change_info.blank?
        agent_change_info = AgentChangeInfo.new( user_id: self.user_id,company_name_old: self.company_name,
                                        company_name_new: company_name_new, status: PENDING, 
                                        action: CHANGE_COMPANY_NAME)
        first_times = true
      else
        first_times = false
        gt_month = agent_change_info.updated_at.utc < Time.now.utc - 1.minute
        agent_change_info.company_name_new = company_name_new
      end
      if agent_change_info.save
        begin
          if first_times
            self.update!(edit_company_name_state: UNKNOWN)
            message = I18n.t 'saveCompanyName_success_gt_30'
          else
            if gt_month
              self.update!(edit_company_name_state: UNKNOWN)
              message = I18n.t 'saveCompanyName_success_gt_30'
            else
              self.update!(edit_company_name_state: PENDING)
              message = I18n.t 'saveCompanyName_success_ltq_30'
            end
          end
          return true, message
        rescue Exception => e
          puts "============errors"
          p e
          return false, ""
        end
      end
      puts "=========error"
      puts agent_change_info.errors.inspect
      return false
  end

  def save_fullname(first_name_new, last_name_new)
      agent_change_info = AgentChangeInfo.find_by(user_id: self.user_id,status: PENDING,action: CHANGE_PROFILE)
      if agent_change_info.blank?
        agent_change_info = AgentChangeInfo.new(first_name_new: first_name_new, first_name_old: self.first_name, last_name_new: last_name_new, 
                                        last_name_old: self.last_name, user_id: self.user_id,
                                        status: PENDING,action: CHANGE_PROFILE)
      else
        agent_change_info.first_name_new = first_name_new
        agent_change_info.last_name_new = last_name_new
      end
      if agent_change_info.save
        begin
          self.update!(edit_profile_state: PENDING)
          return true  
        rescue Exception => e
          p e
          return false
        end
      end
      return false
  end

  def push_notification_online
      customer_location_alerts = CustomerLocationAlert.where("time_expired > (?) and is_alert IS TRUE",Time.now).within(DEFAULT_RADIUS,:units => :miles, origin: [self.latitude, self.longitude])
      user_ids = customer_location_alerts.select("user_id")
      customer_devices = CustomerDevice.where(user_id: user_ids)
      unless customer_location_alerts.blank? || customer_devices.blank?
      sns = Aws::SNS::Client.new
     p "======================================"
     p customer_devices
      customer_devices.each do |customer_device|
        customer_device.push_notification_agent_online(self)
      end
    end
  end
  def push_notification_apply_change(message,change_info)
     customer_devices = self.user.customer_devices
     unless customer_devices.blank?
        customer_devices.each do |customer_device|
          customer_device.push_notification_change_first_last_name(message,change_info)
        end 
        
     end
  end

  def push_notification_change_license(status)
    customer_devices = self.user.customer_devices
    unless customer_devices.blank?
        customer_devices.each do |customer_device|
          customer_device.push_notification_change_license(status,self)
        end 
        
     end
  end

  def push_notification_apply_change_company(message,change_info)
     customer_devices = self.user.customer_devices
     unless customer_devices.blank?
        customer_devices.each do |customer_device|
          customer_device.push_notification_change_company_name(message,change_info)
        end 
        
     end
  end


  def push_notification_to_agent_background(type,customer,sharing)
    customer_devices = self.user.customer_devices
     unless customer_devices.blank?
        customer_devices.each do |customer_device|
          customer_device.push_notification_background(type,self,customer,sharing)
        end 
        
     end

    
  end

  def self.get_total_agent_from_current_location(latitude, longtitude)
    radius = DEFAULT_RADIUS
     total_agents = Agent.joins(:user).where("users.is_online = true").near([latitude, longtitude], radius, :units => :mi)
     #total_agents = Agent.joins(:user).near([latitude, longtitude], radius, :units => :mi)
     while total_agents.size.to_i <= MAX_AGENTS_TOTAL  && radius < MAX_RADIUS
        p total_agents.size.to_i
        radius += DEFAULT_RADIUS
        total_agents = Agent.joins(:user).where("users.is_online = true").near([latitude, longtitude], radius, :units => :mi)
        #total_agents = Agent.joins(:user).near([latitude, longtitude], radius, :units => :mi)

     end

     total_agents.size.to_s
  end

  def is_holdon?
    self.edit_profile_state == PENDING or self.edit_company_name_state == PENDING
  end
end
