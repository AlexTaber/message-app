//has to go on users site
jQuery(document).ready(function($){
<<<<<<< HEAD
    var opened = false
    $( "#pwd-open-btn" ).click(function() {
            $( "#fixed-iframe" )
              .toggleClass("pwd-open");
              if($( "#fixed-iframe" ).hasClass('pwd-open')) {
                $('#pwd-open-btn').text('X');
              } else {
                $('#pwd-open-btn').text('---');
              }
              opened = true
      });

});

//our js
jQuery(document).ready(function($){
  msgBxDropdowns('#pwd-users', '#msg-bx-users-pwd');
  msgBxDropdowns('#pwd-sites', '#msg-bx-sites-pwd');
  msgBxDropdowns('#pwd-convos', '#msg-bx-convos-pwd');
  $(".new_message").submit(sendMessage);
});

function msgBxDropdowns(clicked, target){
  $(clicked).on('click',function(){
      $('.msg-bx-dropdown-pwd').slideUp();
      $('i.active').removeClass('active')
      $(target).slideToggle();
      $(this).toggleClass('active');
  });
}

function sendMessage(e) {
  e.preventDefault();
  $.ajax({
    url: "http://localhost:3000/messages",
    method: "POST",
    data: $(e.target).serialize()
  }).done(function(response){
    $(".msg-bx-convo-pwd").append(response);
    $(".new_message").find("#message_content").val("");
    scrollToBottom();
  });
}

function scrollToBottom() {
  var tar = $(".msg-bx-convo-pwd");
  tar.scrollTop(tar[0].scrollHeight - tar.height())
}
