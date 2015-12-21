//has to go on users site
jQuery(document).ready(function($){
    var opened = false
    $( "#pwd-open-btn" ).click(function() {
            $( "#fixed-iframe" )
              .toggleClass("pwd-open");
              if($( "#fixed-iframe" ).hasClass('pwd-open')) {
                $('#pwd-open-btn').text('X');
              } else {
                $('#pwd-open-btn').html('&#9650;');
              }
              opened = true
      });
});