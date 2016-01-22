//has to go on users site
jQuery(document).ready(function($){
    $( "#pwd-open-btn" ).click(function() {
        $( ".pwd-init" )
          .removeClass('pwd-init')
            $( "#fixed-iframe" )
              .toggleClass("pwd-closed");
              if($( "#fixed-iframe" ).hasClass('pwd-closed')) {
                $('#pwd-open-btn').html('+');
              } else {
                $('#pwd-open-btn').text('_');
              }
        
      });
});