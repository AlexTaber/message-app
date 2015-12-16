jQuery(document).ready(function($){
  $.ajax({
    url: "http://localhost:3000/home",
    method: "GET",
    data: {
      apples: "APPLES INDEED"
    }
  }).done(function(user_id){

  });
// message box
$( ".msg-bx-open-button-pwd, .msg-bx-close-pwd" ).click(function() {
  $('.msg-bx-pwd').css({'top': 'auto', 'width':'auto'});
        $( ".msg-bx-is-open-pwd, .change-convo-pwd" )
          .slideToggle("slow");
        $( ".msg-bx-pwd")
          .toggleClass("msg-open-pwd");
        if($('.msg-bx-pwd').hasClass('msg-open-pwd')){
          $('.msg-bx-header-txt-pwd').html("Your Messages With Joe Dell &nbsp;<a href='#' class='change-convo-pwd'>Message Another User</a>");
        } else {
          $('.msg-bx-header-txt-pwd').text("This is Your Message Center");
        }
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