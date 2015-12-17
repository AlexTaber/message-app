jQuery(document).ready(function($){
  $.ajax({
    url: "http://localhost:3000/message_box",
    method: "GET",
    data: {
      url: document.location.origin
    }
  }).done(function(response){
    $("body").append(response);

    // message box
    $( ".msg-bx-open-button-pwd, .msg-bx-close-pwd" ).click(function() {
      $('.msg-bx-pwd').css({'top': 'auto', 'width':'auto'});
            $( ".msg-bx-is-open-pwd, .change-convo-pwd" )
              .slideToggle("slow");
            $( ".msg-bx-pwd")
              .toggleClass("msg-open-pwd");
      });
    $('.msg-bx-close-pwd, .msg-bx-users-pwd li').on('click', function(){
      $('.msg-bx-users-pwd').slideUp();
    });
    $('.change-convo-pwd').on('click', function(e){
        e.preventDefault();
        $('.msg-bx-users-pwd').slideToggle();
    });
    $('.msg-bx-pwd').draggable({axis: 'x',
      containment: "window",
        });
  });
});