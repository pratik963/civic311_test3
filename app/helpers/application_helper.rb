module ApplicationHelper

	def sortable(column, title = nil)
	  title ||= column.titleize
  	  css_class = column == sort_column ? "current #{sort_direction}" : nil
      direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
  
	  per_page =10;
	  per_page = params[:per_page] ? params[:per_page] : 10;
	  params[:per_page]=per_page;
	  param1 = params[:param1] ? params[:param1] : 1;
	
      link_to title, {:sort => column, :direction => direction, :per_page => per_page, :param1 => param1}, {:class => css_class}
	end	
	
end
