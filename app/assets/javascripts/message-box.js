
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
  msgBxDropdowns('#pwd-users', '#msg-bx-users-pwd');
  msgBxDropdowns('#pwd-sites', '#msg-bx-sites-pwd');
  msgBxDropdowns('#pwd-convos', '#msg-bx-convos-pwd');
});
function msgBxDropdowns(clicked, target){
  $(clicked).on('click',function(){
      $('.msg-bx-dropdown-pwd').slideUp();
      $('i.active').removeClass('active')
      $(target).slideToggle();
      $(this).toggleClass('active');
  });
}