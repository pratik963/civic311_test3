class Customer < ActiveRecord::Base

  self.table_name = "customers"
  self.primary_key = 'id'

  #reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode

  validates :phone_number, uniqueness: true
  
 # has_many :connections, :dependent => :delete_all
  has_many :wishlists, :inverse_of => :customer
  has_many :request_showings, :inverse_of => :customer
  has_many :ratings, :inverse_of => :agent
  belongs_to :language1, :class_name => "Language", :foreign_key => "preferred_language_id_1"
  belongs_to :language2, :class_name => "Language", :foreign_key => "preferred_language_id_2"
  belongs_to :user, :inverse_of => :customer

  #rails_admin do
    #configure :connections do
      #visible(false)
    #end
  #end

  def name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    end
  end

  def as_json 
    user = User.find_by(id: self.user_id)
    {
      authentication_token: user.authentication_token,
      email:                user.email,
      customer_id:          self.id,
      phone_number:         self.phone_number,
      phone_verified:       self.phone_verified,
      first_name:           self.first_name,
      last_name:            self.last_name,
      inital_contact:       self.inital_contact,
      language_1:           self.preferred_language_id_1,
      language_2:           self.preferred_language_id_2
    }
  end 

  def as_json2 
    user = User.find_by(id: self.user_id)
    {
      authentication_token: user.authentication_token,
      email:                user.email,
      customer_id:          self.id,
      phone_number:         self.phone_number,
      phone_verified:       self.phone_verified,
      first_name:           self.first_name,
      last_name:            self.last_name,
      inital_contact:       self.inital_contact,
      language_1:           self.language1.try(:name),
      language_2:           self.language2.try(:name),
    }
  end 

  # Get rating information
  def get_rating_information(agent_id)
    ratings = Rating.where(agent_id: agent_id)
    numCustomerRates = ratings.distinct.count(:customer_id)
    avgAll = ratings.average('rate').to_f
    avgCategory = ratings.joins(:rating_question).group('category').average('rate').map{|category, rate| {category: category, rate: rate}}
    ratings = ratings.where(customer_id: self.id)
    avgQuestion = ratings.group('rating_question_id').average('rate').map{|question, rate| {question: question, rate: rate}}

    rating_date = ratings.joins(:rating_question).select('category, CAST(MAX(ratings.updated_at) as date) as date').group('category')

    {numCustomerRates: numCustomerRates, avgAllRates: avgAll, avgCategory: avgCategory, avgQuestion: avgQuestion, rating_date: rating_date}
  end
end
