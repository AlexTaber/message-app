//our js
var canSendMbMessage = true;
var shiftPressed = false;

jQuery(document).ready(function($){
  scrollToBottom();

  //PUSHER--------------------------
  if(typeof conversationTokens !== 'undefined') {
    var channel;
    var conversationToken;
    for(var i = 0; i < conversationTokens.length; i++) {
      conversationToken = conversationTokens[i];
      subscribeToMbConvo(conversationToken, curConvoToken);
    }
  }

  listenForNewMbConvos();
  //END PUSHER----------------------

  $('.mb-body').hide();
  //dropdowns
  msgBxDropdowns('#projects-btn', '#mb-projects-dropdown');
  msgBxDropdowns('#convos-btn', '#mb-convos-dropdown');
  msgBxDropdowns('#acct-btn', '#mb-acct-dropdown');

 var tasksUrl = window.location.href.indexOf("tasks") > -1
 if(tasksUrl){
  $('#tasks-btn').addClass('is-active');
 }

  //enterSubmit('#message_content', '#new_message');
  enterSubmit('#content', '#new-conversation-form');

  //$(".new_message").submit(sendMbMessage);
  $("#new-conversation-form").submit(startMbConversation);
  //conversation dropdown tabs

  $('.flash').delay(3000).fadeOut();

  //hide dropdowns on window resize
    if ($('body').height() > 100) {
      $('.mb-body').fadeIn();
    }
  $(window).on('resize', function(){
    if ($('body').height() < 100) {
      $('.mb-dropdown').hide();
      $('i.is-active').removeClass('is-active');
      $('.mb-body').fadeOut(200);
      if($('.flash')[0]){
      $('.flash').hide();
    }
    }
    if ($('body').height() > 100) {
      $('.mb-body').fadeIn();
    }
  });

  $('.mb-body_add-users-btn').on('click', function(e){
    e.preventDefault();
    $('.add-focus').focus();
  });
});

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
function msgBxDropdowns(clicked, target){
$(clicked).on('click',function(){
  if($(this).hasClass('is-active')) {
    $('.mb-dropdown').slideUp();
    $(this).toggleClass('is-active');
  } else {
    $('.mb-dropdown').slideUp();
    $('i.is-active').removeClass('is-active')
    $(target).slideToggle();
    $(this).toggleClass('is-active');
  }
});
}

function sendMbMessage(e) {
  console.log("HERE");
  e.preventDefault();
  if(messageSendable()) {
    canSendMbMessage = false;
    $.ajax({
      url: e.target.action,
      method: "POST",
      data: $(e.target).serialize()
    }).done(function(response){
      canSendMbMessage = true;
      $(".new_message").find("#message_content").val("");
      scrollToBottom();
    });
  }
}

function startMbConversation(e) {
  e.preventDefault();
  $("#ajax-loader").show();

  $.ajax({
    url: e.target.action,
    method: "POST",
    data: $(e.target).serialize()
  }).done(function(data){
    $("#ajax-loader").hide();
    canSendMbMessage = true;
    curConvoToken = data.token;
    $("#mb-form-wrapper").html(data.form_html);
    $("#av-message-form").submit(sendMbMessage);
    enterSubmit('#message_content', '#av-message-form');
    if(tasksMode) {
      $(".pending-tasks-mb").prepend(data.html);
    } else {
      $(".msg-bx-convo").append(data.html);
    }
    subscribeToMbConvo(data.token, curConvoToken);
  });
}

function scrollToBottom() {
  var tar = $(".msg-bx-convo");
  if( tar.length > 0) {
    tar.scrollTop(tar[0].scrollHeight - tar.height())
  }
}

function messageSendable() {
  var content = $(".new_message").find("#message_content").val();
  if(canSendMbMessage && content != "") {
    return true;
  }
  return false;
}

function addNewLine(form) {
  var tar = $(form).find("textarea");
  var value = tar.val();
  tar.val(value);
}

function subscribeToMbConvo(conversationToken, curConvoToken) {
  channel = pusher.subscribe('conversation' + String(conversationToken) + String(userId));
  channel.bind('new-message', function(data) {
    if(curConvoToken == data.conversation_token) {
      if(notesMode) {

      } else if(tasksMode) {
        $(".pending-tasks-mb").prepend(data.task_html);
      } else {
        if(userId == data.user_id) {
          $(".msg-bx-convo").append(data.current_user_html);
        } else {
          $(".msg-bx-convo").append(data.other_user_html);
        }
      }

      scrollToBottom();
    }
  });
}

function listenForNewMbConvos() {
  channel = pusher.subscribe('new-conversation' + String(userId));
  channel.bind('new-conversation', function(data){
    if(projectId == data.project_id) {
      $("#convos-list").append(data.mb_html);
    }
  });
}