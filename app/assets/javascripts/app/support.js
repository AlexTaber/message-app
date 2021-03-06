$(document).ready(function() {

  $("#faq-click").on('click', faqClick);
  $("#tutorials-click").on('click', tutorialsClick);
  $(".tutorial-card-container").on('click', videoClick);
  $("#video-modal").on('click', closeVideo);

});

function faqClick() {
  $(".tutorials").fadeOut(500, function() { $(".faq").fadeIn(500); });
  contentScroll();
}

function tutorialsClick() {
  $(".faq").fadeOut(500, function() { $(".tutorials").fadeIn(500); });
  contentScroll();
}

function contentScroll() {
  var targetHeight = $("#scroll-div").scrollTop();
  targetHeight = targetHeight + $("#support-content-wrapper").offset().top - 50;

  $("#scroll-div").animate({
    scrollTop: targetHeight
  }, 650);
}

function videoClick() {
  var source = $(this).data('source');
  var modal = $("#video-modal");
  modal.fadeIn(500);
  setTimeout(function() {
    modal.children("iframe").attr("src", source);
  }, 200);
}

function closeVideo () {
  var modal = $("#video-modal");
  modal.fadeOut(500);
  modal.children("iframe").attr("src", "");
}