class AdminController < ApplicationController

  helper_method :sort_column, :sort_direction

  #require 'json'
  #require 'active_support'
  #require 'active_support/core_ext'

  def index
  
    get_table_name #method for table_names and model_names 

    get_table_column_name # method for table_name, column_names and model_name 

    get_table_data # method for table data

    @model_data = []
    
    @model_data = @model_name.order(sort_column + " " + sort_direction).page(params[:page]).per(10)

    respond_to do |format|
	    format.html
	    format.json
  	end

  end

  def get_table_name

  	@temp_table = []

  	@model_names = []

  	ActiveRecord::Base.connection.tables.each do |table|      
  	  @temp_table <<  {:table_name => table}
  	  
  	  @model_names << table.classify
  	  
    end

  end

  def get_table_column_name

  	@table = params[:param1].present? ? params[:param1] : @temp_table[0][:table_name]

  	@model_name = params[:param1].present? ? params[:param1].classify.constantize : @temp_table[0][:table_name].classify.constantize
   	
   	@column_name = []
   
    ActiveRecord::Base.connection.columns(@table).each { |c|	
  		@column_name << c.name
  	}
  end

  def get_table_data

  	@column_data = []

  	table = @table

  	current_page = current_page || 1
	per_page = 10
	records_fetch_point = (current_page - 1) * per_page

  	@column_data = ActiveRecord::Base.connection.execute("SELECT * FROM #{table}").to_a

	@column_data = Kaminari.paginate_array(@column_data).page(params[:page]).per(10)

  end	

  def dashboard

  	get_table_name

  end

  def show
  	get_table_name
   
    @id = params[:id]
    @name = params[:name]

  end

  def new

  	get_table_name
  	get_status
  	get_action

    @h = {}
    ActiveRecord::Base.connection.columns(params[:param2]).each { |c|	
  		@h.store(c.name, c.type)
  	}

  end	

  def create

  	get_table_name

  	params[:param2] = params[:hidden_one]
  	
    if params[:param2].present?

		col = params["#{params[:param2]}"].map { | key, value | eval key.inspect}.join(', ')
	    
	    val = params["#{params[:param2]}"].map { | key, value | value.inspect }.join(', ') 
		
		records_array = []

  	  	sql = "INSERT into #{params[:param2]} (#{col}) VALUES (#{val})"

	  	records_array = ActiveRecord::Base.connection.execute(sql)

      	redirect_to :action => "index",:param1 => "#{params[:param2]}"

    else
      	render('new') 
    end  

  end 

  def edit

  	get_table_name
  	get_status
  	get_action

    @id = params[:id]
    params[:param2] = params[:name]

    @h = {}
    ActiveRecord::Base.connection.columns(params[:param2]).each { |c|	
  		@h.store(c.name, c.type)
  	}
  end

  def update
  	
  	get_table_name

   	@id = params[:id]
   	params[:param2] = params[:hidden_one]

	params["#{params[:param2]}"].map { | key, value | 

	ActiveRecord::Base.connection.execute("UPDATE #{params[:param2]} SET #{key}='#{value}' WHERE id = '#{params[:id]}'")
	
	}
  
    redirect_to :action => "index",:param1 => "#{params[:param2]}"
  end   

  def delete
    @id = params[:id]
    @name = params[:name]
  end

  def destroy
  	get_table_name

   	id = params[:id]
    name = params[:name]
   
    ActiveRecord::Base.connection.execute("DELETE from #{name} where id = '#{id}'")
  	
    redirect_to :action => "index",:param1 => "#{name}"
  end 

  def export
  	begin
  		get_table_name

		table_model_name = params[:param1].present? ? params[:param1].classify : @temp_table[0][:table_name].classify

		if table_model_name.blank? 
			render :json => {:status_code => 401, :message => "Model name blank is not allowed" }
			return
		end

		table_model=nil;

		begin
			table_model = table_model_name.constantize
		rescue => ex
			render :json => {:status_code => 401, :message => "Model name not found or is incorrect" }
			return
		end
	   	
		model_data = table_model.first

		if !model_data
			 render :json => {:status_code => 401, :message => "Model Data not found" }
			return
		end
	   
		model_field={}

		model_field[table_model_name] = []

		model_field["association"] = {}
	   
		model_data.attributes.each_pair do |name, value|
			model_field[table_model_name].push(name)
		end
	  
		  ##find all relational model and fields 
		  associations = table_model.reflect_on_all_associations(:has_many) 
		  
		  if associations.count >= 0
			  associations.each do |association|
				association_name = association.name.to_s
				
				model_field["association"][association_name]=[]
				
				table_model = association_name.classify.constantize;
				table_model.columns.each do |col|
				  model_field["association"][association_name].push(col.name)
				end
				
			  end
		  end

		 @model_field = model_field

		 render :action => "export"

	rescue => ex
		 render :json => {:status_code => 401, :message => "Model Data have problem" }
		 return
	end   
  end	

  def export_sel_fields

  	begin

	  model_hash = {
		"PromotionCode"		=> { "PaymentTransaction" => "promotion_id"},
		"Wishlist"			=> { "RequestShowing" => "attached_wishlist", "Sharing" => "wishlist_id"},
		"InvestingWishlist" => { "InvestingWishlistType" => "investing_wishlist_id"},
		"InvestmentType" 	=> { "InvestingWishlistType" => "investment_type_id"},
		"RequestShowing" 	=> { "Sharing" => "request_id"},
		"Customer"  		=> { "Wishlist" => "customer_id", "RequestShowing" => "customer_id", "Rating" => "customer_id"},
		"Sharing"			=> { "Connection" => "sharing_id"},
		"PropertyType" 		=> { "BuyingWishlist" => "property_type_id", "SellingWishlist" => "property_type_id", "RentingWishlist" => "property_type_id"},
		"Agent"				=> { "Acceptance" => "agent_id", "AgentLanguage" => "agent_id", "AgentSpecialty" => "agent_id", "AgentDesignation" => "agent_id", "AgentZipCode" => "agent_id", "License" => "agent_id", "PaymentTransaction" => "agent_id" },
		"Language"			=> { "Customer" => "preferred_language_id_1", "Customer" => "preferred_language_id_2", "AgentLanguages" => "language_id" },
		"Connection"	    => { "Customer" => "customer_id" },
		"User"	 		    => { "Issue" => "user_id", "Suggestion" => "user_id", "CustomerDevice" => "user_id", "CustomerLocationAlert" => "user_id", "AgentChangeInfo" => "user_id"}
	  }
					 
	
		table_model_name = [] , column_array =[], associated_model_array= []
		as_csv1 = CSV.generate do |csv|	
			params[:ids].each do |key,value|
				key_name = key.titleize
				value.each do |i|
					column_name = key_name + "_"+i 
					column_array.push(column_name)
				end				 				
			end	
			csv <<	column_array			
			main_model = params[:model_name] ?  params[:model_name]  : "";
			
			
			params[:ids].each_with_index do |value,index|	
				if index != 0
					associated_model_array.push(value)
				end				
			end	
			
			
			main_model_ids_for_pluck = params[:ids]["#{main_model}"]
			main_model_ids_for_pluck = main_model_ids_for_pluck.collect { |x| "`" + x + "`" } 

			
			
			main_model_ids_for_pluck = main_model_ids_for_pluck.join(',')
			
				main_model_const = main_model.constantize
			
			
			row_array = []
			
			
			main_model_data = main_model_const.all.select(main_model_ids_for_pluck)
			main_model_data.each do |abc|
				s = abc.attributes.values
				s.each do |g|
					row_array.push(g)
				end
				associated_model_array.each do |ass_model_data|
					ass_model_name = ass_model_data[0]
					ass_model_ids = ass_model_data[1]
					ass_model_ids = ass_model_ids.collect { |x| "`" + x + "`" } 
					ass_model_name = ass_model_name.titleize.singularize.split(' ').join('').constantize

					 logger.info ">>>ass_model_ids>>>#{ass_model_ids}"
					
					 logger.info ">>>ass_model_idsnew>>>#{ass_model_ids}"

					main_model_id = "#{main_model.downcase}_id"
					
					
					 logger.info ">>>main_model>>>#{main_model}>>>ass_model_name>>>#{ass_model_name}"
					 logger.info ">>>model_hash>>>#{model_hash["#{main_model}"]["#{ass_model_name}"]}"
					 select_id = model_hash[main_model.to_s][ass_model_name.to_s].to_s
					 logger.info "select_id>>>#{select_id}"
					
					ass_model_table_data = ass_model_name.where("#{select_id} = #{abc.id.to_i}").select(ass_model_ids.join(','))
					if ass_model_table_data.length == 0
						tmp_d = ass_model_ids.map{|a| "" }
						tmp_d.each do |eee1|
							row_array.push(eee1)
						end
						# row_array.push(tmp_d)
					elsif ass_model_table_data.length == 1
						ass_model_table_data.each do |ass|
							ass_data = ass.attributes.values
							ass_data.each do |tmp|
								row_array.push(tmp)
								# logger.info ">>>tmp>>>#{tmp}"
							end
						end
					else
					
						
						arrayList = []
						ass_model_table_data.each do |ass|
							arrayList.push(ass.attributes.values.join(','))
							
						end
						logger.info ">>>arrayList>>>#{arrayList}"
						
						ass_model_table_data_values=[]
						(0...ass_model_table_data[0].attributes.values.length).each{|i|
							tmp1 =[]
							(0...arrayList.length).each{|j|
								tmp1.push(arrayList[j][i])
							}
						  ass_model_table_data_values.push(tmp1)
						}
						logger.info ">>>ass_model_table_data_values>>>#{ass_model_table_data_values}"
						ass_model_table_data_values.each do |eee|
							row_array.push(eee.join(','))
						end
						
							
					end
					
					
				end
				csv << row_array
				row_array = []
			
			
			end
			Rails.logger.info ">>>>>main_model_data>>>>> #{main_model_data}"
				
		end	
	
		csv_file="expost_data";	
		send_data as_csv1, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment;data=#{csv_file}.csv"	  
		
	rescue => ex
		logger.info ">>>#{ex}"
		render :json => {:status_code => 401, :message => "Export Data have problem" + ex.message }
		return
	end

  end

  def get_status
	@status_array  = [ 
      {:id => "pending", :status => "pending" },
      {:id => "approved", :status => "approved" },
      {:id => "reject", :status => "reject" }
     ]
	return  @status_array 
  end

  def get_action
	@action_array  = [ 
      {:id => "change_profile", :action => "change_profile" },
      {:id => "change_company_name", :action => "change_company_name" }
     ]
	return  @action_array  
  end

  private

  def sort_column
  	get_table_column_name
    @model_name.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
