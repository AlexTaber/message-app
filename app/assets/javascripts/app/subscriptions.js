(function() {

  jQuery(function() {
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
    return subscription.setupForm();
  });
  subscription = {
    setupForm: function() {
      return $('#subscription-form').submit(function() {
        $('input[type=submit]').attr('disabled', true);
        if ($('#card_number').length && !$('#_tier_id_1').is(':checked')) {
          subscription.processCard();
          return false;
        } else {
          return true;
        }
      });
    },
    processCard: function() {
      var card;
      card = {
        number: $('#card_number').val(),
        cvc: $('#card_code').val(),
        expMonth: $('#card_month').val(),
        expYear: $('#card_year').val()
      };
      return Stripe.createToken(card, subscription.handleStripeResponse);
    },
    handleStripeResponse: function(status, response) {
      debugger;
      if (status === 200) {
        $('#subscription_stripe_card_token').val(response.id);
        return $('#subscription-form')[0].submit();
      } else {
        $('#stripe_error').text(response.error.message);
        return $('input[type=submit]').attr('disabled', false);
      }
    }
  };

  $(document).ready(function() {
    $('.tiers_card').on('click', function(){
    var i = $(this).parent().children().index(this)
      if(!$(this).hasClass('is-active')){
        $('.is-active').removeClass('is-active');
        $(this).addClass('is-active');
      }
      if(!$('.tier-select input').eq(i).is(':checked')){
       $('.tier-select input').eq(i).prop('checked', true);
      }
      if($(this).is(':first-of-type')){
        hideCardForm();
      } else {
        showCardForm();
      }
    });
  });

  function hideCardForm() {
    $("#card-form").slideUp(500);
  }

  function showCardForm() {
    $("#card-form").slideDown(500);
  }
  // function transitionSubscriptionText() {
  //   index = $(this).attr("value");

  //   newDollar = $("#dollar-" + index);
  //   curDollar.removeClass("is-transitioned");
  //   newDollar.addClass("is-transitioned");
  //   curDollar = newDollar;

  //   newST = $("#subscription-text-" + index);
  //   curST.addClass("is-hidden");
  //   setTimeout(function() {
  //     newST.removeClass("is-hidden");
  //   }, 500);
  //   curST = newST;

  //   subTransition(parseInt(index));
  // }

  // function subTransition(index) {
  //   var colors = [
  //     "#56688f",
  //     "#455372",
  //     "#133c64"
  //   ]

  //   var fontColors = [
  //     "#fff",
  //     "#fff",
  //     "#fff"
  //   ]

  //   $(".subscription-info").css({
  //     "background-color": colors[index - 1],
  //     "color": fontColors[index - 1]
  //   });
  // }
}).call(this);