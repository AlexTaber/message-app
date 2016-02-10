///APP Header
var canSendMessage = true;
jQuery(document).ready(function($){
  scrollToBottom();
    //sidr
  jQuery("#right-menu").sidr({name:"sidr-right", side:"right"})

  //PUSHER--------------------------
  if(typeof conversationTokens !== 'undefined') {
    var channel;
    var conversationToken;
    for(var i = 0; i < conversationTokens.length; i++) {
      conversationToken = conversationTokens[i];
      subscribeToConvo(conversationToken, curConvoToken);
    }
    listenForNewConvos();
  }

  //if user clicks conversation on mobile

  var messageUrl = window.location.href.indexOf("user_ids") > -1
  var convoUrl = window.location.href.indexOf("user_ids") > -1
  var newConversationUrl = window.location.href.indexOf("new_conversation") > -1
  var mediaSize = $('body').width() < 750
  if (( messageUrl || newConversationUrl) && mediaSize) {
    $('.mobile-target').fadeOut(0);
    $('#current-account').slideUp();
    $('.mobile-target').eq(2).fadeIn();
    $('.mobile-active').removeClass('mobile-active')
    $('#mobile-messages').addClass('mobile-active');
  }

  //END PUSHER----------------------

  // User Chevron ------------------
  $('.menu-caret').on('click', function(){
    $(this).toggleClass('rotated');
  });
  $('.site-target').on('click', function(){
    $(this).siblings('.menu-caret').toggleClass('rotated');
  });

  // Send Message-------------------
  $("#av-message-form").submit(sendMessage);
  $("#new_conversation").submit(startConversation);
  //--------------------------------

  //add user to conversation
  $('.add-user-to-convo').on('click', function(){
    $('.add-focus').focus();
  })
  //----------------

  //manage user edit ----------------
  $('.manage-user-edit').on('click', function(){
    $(this).siblings('span').fadeToggle();
  })
  //enter submit
  enterSubmit('#message_content', '#av-message-form');
  enterSubmit('#content', '#new_conversation');
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

  //flash messages fade out after 3 sec
	$('.flash').delay(3000).fadeOut();

//Tabs

$(".tab-list .tab1 a").click(function(e) {
    e.preventDefault();
    $(".tabs .active-tab").removeClass("active-tab");
    $(".tab1").addClass("active-tab");
});

$(".tab-list .tab2 a").click(function(e) {
    e.preventDefault();
    $(".tabs .active-tab").removeClass("active-tab");
    $(".tab2").addClass("active-tab");
});


// $(".close-new-convo").on('click', function(e){
//   e.preventDefault();
//   $('.new-convo-placeholder').hide();
// });


$("#profile-uploader").change(function(){
    readURL(this);
});

});
$(window).on('load',function(){
  $('.new-focus').focus();
});

//Functions
function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {
            $('#img-input').fadeIn().attr('src', e.target.result);
        }

        reader.readAsDataURL(input.files[0]);
    }
}
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
  if(newMessageSendable()) {
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
      $('.new-convo-placeholder').slideUp();
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

function newMessageSendable() {
  var content = $(".new_conversation").find("#content").val();
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
        $(".app-view").append(anchorme.js(data.current_user_html, { "target":"_blank" }));
      } else {
        $(".app-view").append(anchorme.js(data.other_user_html, { "target":"_blank" }));
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
      var newConvoEl = $(".new-convo-placeholder");

      if(newConvoEl.length) {
        newConvoEl.after(anchorme.js(data.app_html, { "target":"_blank" }));
      } else {
        $(".current-site-data").after(data.app_html);
      }
    }
  });
}