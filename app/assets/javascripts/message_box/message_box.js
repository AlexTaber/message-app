//our js
jQuery(document).ready(function($){
  msgBxDropdowns('#pwd-users', '#msg-bx-users-pwd');
  msgBxDropdowns('#pwd-sites', '#msg-bx-sites-pwd');
  msgBxDropdowns('#pwd-convos', '#msg-bx-convos-pwd');
  enterSubmit('#message_content', '#new_message')
  $(".new_message").submit(sendMessage);
  $(".new_conversation").submit(startConversation);
  $('.msg-bx-convo-pwd').scrollTop($('.msg-bx-convo-pwd')[0].scrollHeight);
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
      $('.msg-bx-dropdown-pwd').slideUp();
      $(this).toggleClass('active');
    } else {
      $('.msg-bx-dropdown-pwd').slideUp();
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
    $(".msg-bx-convo-pwd").append(response);
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
    $(".msg-bx-convo-pwd").append(response);
    $(".new_conversation").find("#content").val("");
    scrollToBottom();
  });
}

function scrollToBottom() {
  var tar = $(".msg-bx-convo-pwd");
  tar.scrollTop(tar[0].scrollHeight - tar.height())
}
