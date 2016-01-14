///APP Header
var canSendMessage = true;
jQuery(document).ready(function($){
  scrollToBottom();
  //PUSHER--------------------------
  if(typeof conversationTokens !== 'undefined') {
    var channel;
    var conversationToken;
    for(var i = 0; i < conversationTokens.length; i++) {
      conversationToken = conversationTokens[i];
      subscribeToConvo(conversationToken, curConvoToken);
    }
  }
  //if user clicks conversation on mobile

    var messageUrl = window.location.href.indexOf("user_ids") > -1
    var newConversationUrl = window.location.href.indexOf("new_conversation") > -1
    var mediaSize = $('body').width() < 750
    if (( messageUrl || newConversationUrl) && mediaSize) {
      $('.mobile-target').fadeOut(0);
      $('#current-account').slideUp();
      $('.mobile-target').eq(2).fadeIn();
    }

  listenForNewConvos();
  //END PUSHER----------------------

  // User Chevron ------------------
  $('.menu-caret').on('click', function(){
    $(this).toggleClass('rotated');
  })

  // Send Message-------------------
  $("#av-message-form").submit(sendMessage);
  $("#new_conversation").submit(startConversation);
  //-------------------------------

  //add user to conversation
  $('.add-user-to-convo').on('click', function(){
    $('.add-focus').focus();
  })

  //enter submit
  enterSubmit('#message_content', '#av-message-form');
  enterSubmit('#content', '#new_conversation');
  enterSubmit('.tt-input', '.typeahead-form');
  //-----------

	$('#users-account').on('click', function () {
		$('nav#current-account').slideToggle(500);
	});
		dropdowns('#new-message-trigger', '#new-message');
//Accordian
$(".open-accordian").on('click',function() {
          jQuery(this).siblings( ".accordian-content" ).slideToggle(500);
        });

//mobile-nav
$(".mobile-icons i"). on('click', function(){
  $('.mobile-active').removeClass('mobile-active')
  $(this).addClass('mobile-active')
  $('.mobile-target').fadeOut(0);
  $('#current-account').slideUp();
  i = $(this).parent().children().index(this)
  $('.mobile-target').eq(i).fadeIn();
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

	$('.flash').delay(3000).fadeOut();

});

//Functions
function dropdowns(clicked, target){
  $(clicked).on('click',function(){
      $(target).slideToggle();
      $(this).toggleClass('');
  });
}
function close_modal(){
	$('.mask').fadeOut(500);
	$('.modal-window').fadeOut(500);
}
function show_modal(modal_id){
	$('.mask').css({ 'display' : 'block', opacity : 0});
	$('.mask').fadeTo(500,0.8);
	$('#'+modal_id).fadeIn(500);
}

function enterSubmit(input, form) {
  $(input).keypress(function(event) {
    if (event.which == 13) {
      if(event.shiftKey) {
        addNewLine(form);
      } else {
        event.preventDefault();
        $(form).submit();
      }
    }
  });
}

function sendMessage(e) {
  e.preventDefault();
  if(messageSendable()) {
    canSendMessage = false;
    $.ajax({
      url: e.target.action,
      method: "POST",
      data: $(e.target).serialize()
    }).done(function(response){
      canSendMessage = true;
      $(".new_message").find("#message_content").val("");
    });
  }
}

function startConversation(e) {
  e.preventDefault();
  if(messageSendable()) {
    canSendMessage = false;
    $.ajax({
      url: e.target.action,
      method: "POST",
      data: $(e.target).serialize()
    }).done(function(data){
      canSendMessage = true;
      curConvoToken = data.token;
      $("#form-wrapper").html(data.form_html);
      $("#av-message-form").submit(sendMessage);
      enterSubmit('#message_content', '#av-message-form');
      $(".app-view").append(data.html);
      subscribeToConvo(data.token, curConvoToken);
      $(".new_conversation").find("#content").val("");
    });
  }
}

function scrollToBottom() {
  var tar = $(".msg-bx-convo");
  if( tar.length > 0) {
    tar.scrollTop(tar[0].scrollHeight - tar.height())
  }
}

function messageSendable() {
  var content = $(".new_message").find("#message_content").val();
  if(canSendMessage && content != "") {
    return true;
  }
  return false;
}

function subscribeToConvo(conversationToken, curConvoToken) {
  channel = pusher.subscribe('conversation' + String(conversationToken) + String(userId));
  channel.bind('new-message', function(data) {
    if(curConvoToken == data.conversation_token) {
      //if the message is from the current conversation
      if(userId == data.user_id) {
        $(".app-view").append(data.current_user_html);
      } else {
        $(".app-view").append(data.other_user_html);
      }

      scrollToBottom();
    }

    $("#conversation" + String(data.conversation_id)).html(data.app_html);
  });
}

function listenForNewConvos() {
  channel = pusher.subscribe('new-conversation' + String(userId));
  channel.bind('new-conversation', function(data){
    if(siteId == data.site_id) {
      $(".message-bar").append(data.app_html);
    }
  });
}