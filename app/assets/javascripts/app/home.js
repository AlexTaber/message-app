///APP Header 
jQuery(document).ready(function($){
	$('#users-account').on('click', function () {
		$('nav#current-account').slideToggle(500);	
	});
		dropdowns('#requests-icon', '#requests');
//Accordian 
$(".open-accordian").on('click',function() {
          jQuery(this).slideToggle(500).siblings( ".accordian-content" ).slideToggle(500);
        });
///Modal  

var window_width = $(window).width();  
var window_height = $(window).height();  
$('.modal-window').each(function(){  
	var modal_height = $(this).outerHeight();  
	var modal_width = $(this).outerWidth();  
	var top = (window_height-modal_height)/2;  
	var left = (window_width-modal_width)/2;  
	$(this).css({'top' : top , 'left' : left});  
});  

$('.activate-modal').click(function(e){ 
  e.preventDefault();
	var modal_id = $(this).attr('name');  
	show_modal(modal_id);  
});  

$('.close-modal').click(function(){  
	close_modal();  
});  

});
//Functions
function dropdowns(clicked, target){
  $(clicked).on('click',function(){
      $(target).slideToggle();
      $(this).toggleClass('active');
  });
}
function close_modal(){  
	$('#mask').fadeOut(500);  
	$('.modal-window').fadeOut(500);  
}  
function show_modal(modal_id){  
	$('#mask').css({ 'display' : 'block', opacity : 0});  
	$('#mask').fadeTo(500,0.8);  
	$('#'+modal_id).fadeIn(500);  
}  
