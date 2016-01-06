///APP Header
jQuery(document).ready(function($){
  scrollToBottom();
  //PUSHER--------------------------
  var pusher = new Pusher('9cc4489f87803144fa9d');
  var channel;
  var conversationId;
  for(var i = 0; i < conversationIds.length; i++) {
    conversationId = conversationIds[i];
    channel = pusher.subscribe('conversation' + String(conversationId));
    channel.bind('new-message', function(data) {
      if(userId == data.user_id) {
        $(".app-view").append(data.current_user_html);
      } else {
        $(".app-view").append(data.other_user_html);
      }

      scrollToBottom();
    });
  }
  //END PUSHER----------------------

  // Send Message-------------------
  $("#av-message-form").submit(sendMessage);
  //-------------------------------

  //enter submit
  enterSubmit('#message_content', '#av-message-form')
  //-----------

	$('#users-account').on('click', function () {
		$('nav#current-account').slideToggle(500);
	});
		dropdowns('#new-message-trigger', '#new-message');
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

	$('.dismiss').on('click', function(e) {
		e.preventDefault;
		$('.flash').fadeOut();
	});

});
//Functions
function dropdowns(clicked, target){
  $(clicked).on('click',function(){
      $(target).slideToggle();
      $(this).toggleClass('');
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

function enterSubmit(input, form) {
  $(input).keypress(function(event) {
    if (event.which == 13) {
        event.preventDefault();
        $(form).submit();
    }
  });
}

function sendMessage(e) {
  e.preventDefault();
  $.ajax({
    url: e.target.action,
    method: "POST",
    data: $(e.target).serialize()
  }).done(function(response){
    //$(".msg-bx-convo").append(response);
    $(".new_message").find("#message_content").val("");
  });
}

function scrollToBottom() {
  var tar = $(".msg-bx-convo");
  tar.scrollTop(tar[0].scrollHeight - tar.height())
}