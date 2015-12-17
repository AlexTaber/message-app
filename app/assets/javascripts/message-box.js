
  // $.ajax({
  //   url: "http://localhost:3000/message_box",
  //   method: "GET",
  //   data: {
  //     url: document.location.origin
  //   }
  // }).done(function(response){
    //$("body").append(response);

// insert into user's page
jQuery(document).ready(function($){
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
  $('#pwd-users').on('click',function(){
      $('#msg-bx-users-pwd').slideToggle();
      $(this).toggleClass('active')
  });
});