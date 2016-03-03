class RatingQuestion < ActiveRecord::Base
  
  self.table_name = "rating_questions"
  self.primary_key = 'id'

  has_one :ratings, :inverse_of => :rating_question

  def name
    question
  end

  # Get All Rating Question
  def self.get_all_rating_questions
    ratingQuestions = RatingQuestion.pluck(:id, :category, :question).map {|id, category, question| {id: id, category: category, question: question.upcase}}
    ratingQuestions = ratingQuestions.group_by{ |d| d[:category] }.map{|c, q| {category: c, question: q}}.take(3)
    ratingQuestions.each do |rating|
      rating[:question] = rating[:question].take(3)
    end
  end

  #rails_admin do

    #configure :ratings do
      #visible(false)
    #end

  #end
end