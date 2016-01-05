//our js
jQuery(document).ready(function($){

  $('.msg-bx-body').hide();
  //dropdowns
  msgBxDropdowns('#msg-bx-sites-btn', '#msg-bx-sites-drop');
  msgBxDropdowns('#msg-bx-convos-btn', '#msg-bx-convos-drop');
  msgBxDropdowns('#msg-bx-acct-btn', '#msg-bx-acct-drop');

  enterSubmit('#message_content', '#new_message')
  enterSubmit('#content', '#new_conversation')
  $(".new_message").submit(sendMessage);
  $(".new_conversation").submit(startConversation);
  //conversation dropdown tabs
  $('.msg-bx-tab a').on('click', function(e){
    e.preventDefault();
    if($(this).hasClass('inactive')){

      i = $(this).index();
      $('.tab-content>div').fadeOut(0);
      $('.tab-content').children().eq(i).fadeIn();
      $('.msg-bx-tab a').toggleClass('inactive')
    }
  });

  //hide dropdowns on window resize
    if ($('body').width() > 450) {
      $('.msg-bx-body').fadeIn();

    }
  $(window).on('resize', function(){
    if ($('body').width() < 450) {
      $('.msg-bx-dropdown').hide();
      $('i.active').removeClass('active');
      $('.msg-bx-body').fadeOut(200);
    }
    if ($('body').width() > 450) {
      $('.msg-bx-body').fadeIn();

    }
  });
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

