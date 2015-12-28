//has to go on users site
jQuery(document).ready(function($){
    var opened = false
    $( "#pwd-open-btn" ).click(function() {
            $( "#fixed-iframe" )
              .toggleClass("pwd-closed");
              if($( "#fixed-iframe" ).hasClass('pwd-closed')) {
                $('#pwd-open-btn').html('&#9650;');
              } else {
                $('#pwd-open-btn').text('X');
              }
              opened = true
      });
});