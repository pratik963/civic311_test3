class SchemaMigration < ActiveRecord::Base
  
  self.table_name = "schema_migrations"
  self.primary_key = 'id'

end  