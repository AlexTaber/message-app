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
    //https://css-tricks.com/snippets/jquery/draggable-without-jquery-ui/
(function($) {
    $.fn.drags = function(opt) {

        opt = $.extend({handle:"",cursor:"move"}, opt);

        if(opt.handle === "") {
            var $el = this;
        } else {
            var $el = this.find(opt.handle);
        }

        return $el.css('cursor', opt.cursor).on("mousedown", function(e) {
            if(opt.handle === "") {
                var $drag = $(this).addClass('draggable');
            } else {
                var $drag = $(this).addClass('active-handle').parent().addClass('draggable');
            }
            var z_idx = $drag.css('z-index'),
                drg_h = $drag.outerHeight(),
                drg_w = $drag.outerWidth(),
                pos_y = $drag.offset().top + drg_h - e.pageY,
                pos_x = $drag.offset().left + drg_w - e.pageX;
            $drag.css('z-index', 1000).parents().on("mousemove", function(e) {
                $('.draggable').offset({
                    top:e.pageY + pos_y - drg_h,
                    left:e.pageX + pos_x - drg_w
                }).on("mouseup", function() {
                    $(this).removeClass('draggable').css('z-index', z_idx);
                });
            });
            e.preventDefault(); // disable selection
        }).on("mouseup", function() {
            if(opt.handle === "") {
                $(this).removeClass('draggable');
            } else {
                $(this).removeClass('active-handle').parent().removeClass('draggable');
            }
        });

    }
})(jQuery);
  $("#pwd-move-btn").on('click', function(){
    $('.is-draggable').addClass('moved');
  });
  $('#pwd-move-btn').dblclick(function() {
    $('.is-draggable').css({
      'top': 'auto',
      'bottom':'0',
      'right':'50px',
      'left':'auto'
      }).removeClass('moved');
  });
  $( ".is-draggable" ).drags({
    handle: "#pwd-move-btn"
  });
});