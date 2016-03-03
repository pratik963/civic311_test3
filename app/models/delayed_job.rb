class DelayedJob < ActiveRecord::Base

	self.table_name = "delayed_jobs"
    self.primary_key = 'id'

end	