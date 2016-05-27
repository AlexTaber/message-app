//from home document ready

function setUpPricing() {
  setTimeout(function() {
    $("#pricing-button").addClass("is-transitioned");
  }, 2000);

  totalTransitions = $(".transitionable").length;
}