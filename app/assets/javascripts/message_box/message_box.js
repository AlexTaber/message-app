//our js
jQuery(document).ready(function($){
  msgBxDropdowns('#msg-bx-users-btn', '#msg-bx-users-drop');
  msgBxDropdowns('#msg-bx-sites-btn', '#msg-bx-sites-drop');
  msgBxDropdowns('#msg-bx-convos-btn', '#msg-bx-convos-drop');
  enterSubmit('#message_content', '#new_message')
  $(".new_message").submit(sendMessage);
  $(".new_conversation").submit(startConversation);
  $('.msg-bx-convo').scrollTop($('.msg-bx-convo')[0].scrollHeight);
});
function enterSubmit(input, form) {
  $(input).keypress(function(event) {
    if (event.which == 13) {
        event.preventDefault();
        $(form).submit();
    }
});
}
function msgBxDropdowns(clicked, target){
  $(clicked).on('click',function(){
    if($(this).hasClass('active')) {
      $('.msg-bx-dropdown').slideUp();
      $(this).toggleClass('active');
    } else {
      $('.msg-bx-dropdown').slideUp();
      $('i.active').removeClass('active')
      $(target).slideToggle();
      $(this).toggleClass('active');
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
    $(".msg-bx-convo").append(response);
    $(".new_message").find("#message_content").val("");
    scrollToBottom();
  });
}

function startConversation(e) {
  e.preventDefault();
  $.ajax({
    url: e.target.action,
    method: "POST",
    data: $(e.target).serialize()
  }).done(function(response){
    $(".msg-bx-convo").append(response);
    $(".new_conversation").find("#content").val("");
    scrollToBottom();
  });
}
function scrollToBottom() {
  var tar = $(".msg-bx-convo");
  tar.scrollTop(tar[0].scrollHeight - tar.height())
}

