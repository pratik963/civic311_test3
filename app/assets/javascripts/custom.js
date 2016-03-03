/////////////////

/* $(document).ready(function() {
    $('.progress .progress-bar').progressbar();
});

$(document).ready(function () {
   $('.progress .progress-bar').progressbar({
       display_text: 'center',
       done:function(){ //use this option
        setTimeout(function(){
            $(".progressbar-front-text").text("The task is completed");
        },100);//small amount of time to render html 100ms infact
       }
   });    
}); */

/////////////////


	$(document).ready(function(){
		// $('.check_all').on("click", function(){
			//alert($(this).is(':checked'));
			// if($(this).is(':checked') == true){
				// $('.check_row').prop('checked', true);
			// }else{
				// $('.check_row').prop('checked', false);
			// }
			
		// });

		//$('#dd_per_page').selectpicker('refresh');
		//$('#dd_selected').selectpicker('refresh');
		
		$(document).delegate('.check_all',"click", function(){
			//alert($(this).is(':checked'));
			if($(this).is(':checked') == true){
				$('.check_row').prop('checked', true);
			}else{
				$('.check_row').prop('checked', false);
			}
			
		});
		
		
		$('#dd_selected').on("change", function(){
			var selected_val = $(this).val();
			var delete_url="";
			//alert(selected_val);			

			if(selected_val == 2) {
				delete_url= $(this).data("delete-url");
				// alert(delete_url);
				delete_records(delete_url);
			}
		});
		
		
		$('[data-toggle="modal"]').click(function(e) {
			//e.preventDefault()
			//alert("dsf");
			var loadurl = $(this).attr('href');
			var targ = $(this).attr('data-target');
			//alert(loadurl);  alert(targ); 
			$.get(loadurl, function(data) {
				$(targ).html(data)

			});
			//$(this).tab('show')
		});
		
		$(document).delegate('#export_csv',"click", function(){
			//alert("Export Start");
			//return false;
			//var myAjaxVariable = null;
			var main_modal_name = $(this).data("main-modal-name");
			console.log(main_modal_name);
			var export_csv_url = $(this).data("export-url");
			//var model_name = $(this).data("model-name");
			var sel_fields = $("#div_export_model_fields").find(".check_row:checked");
			//alert(sel_fields.toString());
			//return false;
			 var selected = {};
			 sel_fields.each(function() {
				// alert();
				//if(selected != "") { selected =  selected  + ",";}
				// selected =  selected  + $(this).attr("name");
				var model_name =  $(this).data("model-name");
				/* alert(model_name); */
				//return false;
				var field_name =  $(this).data("field-name");
				//alert(field_name);
				if(selected[model_name]) {
					selected[model_name].push(field_name);
				}else{
					selected[model_name] = [];
					selected[model_name].push(field_name);
				}
			});
			console.log(selected);
			/* return false; */
			alert(export_csv_url)
			var jqxhr = $.post(export_csv_url,{ ids: selected , model_name: main_modal_name 
			}).done(function(data) {
				 //alert(data);
				  window.open( "data:text/csv;charset=utf-8," + escape(data));
			}).fail(function() {				
				alert("There was a problem with us receiving your data. Please try again.");
			}).always(function() {
			});
		    return false;
		  
		});
		 
	})
     
	 function delete_records(delete_url){
		 var selected_records= $(".check_row:checked");
		 var selected = "";
		$('.check_row:checked').each(function() {
			if(selected != "") { selected =  selected  + ",";}
			 selected =  selected  + $(this).val();
		});

		// alert(selected);
		//alert(window.location.pathname);
		//alert(window.location.href);

		
		//alert(delete_url);
		//return false

		$.ajax({
		  method: "POST",
		  dataType: "json",
		  url: delete_url,
		  data: { ids: selected }
		})
		  .done(function( data ) {
		    //alert( "data Saved: " + msg );
		    alert(data.message);
		    window.location = data.redirect_url;
		  });
		//  alert("Record deleted");
	 }
	 
 