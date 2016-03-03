class Issue < ActiveRecord::Base
    self.table_name = "issues"
    self.primary_key = 'id'
	belongs_to :user	

	def describe_id
  		"Issue ##{id}"
    end
end
