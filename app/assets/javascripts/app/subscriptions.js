(function() {
  var subscription;
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
    $("#_tier_id_1").click(hideCardForm);
    $("#_tier_id_2, #_tier_id_3").click(showCardForm)
  });

  function hideCardForm() {
    $("#card-form").slideUp(300);
  }

  function showCardForm() {
    console.log("HERE");
    $("#card-form").slideDown(300);
  }
}).call(this);