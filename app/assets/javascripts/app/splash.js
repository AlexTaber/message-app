var curTab = -1;
var tabColors = [
  "#455372",
  "#1379be"
]
var totalTabs;
var scrollDiv;
var navTransitioned = false;
var transitionTime = 5000;
var nextEvent;
var canTransition = true;
var curTransition = 0;
var curTransitionEl;
var transitionOffset = $(window).height() * 0.75;

window.addEventListener ?
window.addEventListener("load",splashLoad,false) :
window.attachEvent && window.attachEvent("onload",splashLoad);

function splashLoad() {
  totalTabs = $(".landing-tab").length;
  totalTransitions = $(".transitionable").length;

  if(totalTabs > 0) {
    //setup tabs
    setTimeout(function() {
      $("#ajax-loader").fadeOut(500);
      nextTab();
      setUpNav();
    }, 200);

    //setup arrows
    $("#right-arrow").on('click', nextTab);
    $("#left-arrow").on('click', prevTab);

    //setup circles
    $(".circle").on('click', clickCircle);
  }
};

function setUpTabs() {
  nextEvent = setTimeout(function() {
    nextTab();
  }, transitionTime);
}

function nextTab() {
  var newTab = (curTab + 1) % totalTabs;
  setTab(newTab);
}

function prevTab() {
  var newTab = curTab - 1;
  if (newTab < 0) { newTab = totalTabs - 1; }
  setTab(newTab);
}

function setTab(newTab) {
  var originalTab = curTab;

  if(canTransition) {
    canTransition = false;
    $("#tab" + String(originalTab)).removeClass("is-active");
    setTimeout(function() {
      $(".navbar").removeClass("tab" + String(originalTab));
      $(".arrow").removeClass("tab" + String(originalTab));
      $("#circle" + String(originalTab)).removeClass("tab" + String(originalTab));
      $("#circle" + String(originalTab)).removeClass("is-active");

      $(".navbar").addClass("tab" + String(newTab));
      $(".arrow").addClass("tab" + String(newTab));
      $("#circle" + String(newTab)).addClass("tab" + String(newTab));
      $("#circle" + String(newTab)).addClass("is-active");

      $("#tab" + String(newTab)).addClass("is-active");
      canTransition = true;
    }, 800);

    curTab = newTab;
    transitionTime = 8000;
    clearTimeout(nextEvent);
    setUpTabs();
  }
}

function setUpNav() {
  scrollDiv = $(".scroll-div");
  scrollDiv.on('scroll', scrollNav);
}

function scrollNav() {
  var top = scrollDiv.scrollTop();

  if(top > 500) {
    if(!navTransitioned) {
      transitionNav();
      clearTimeout(nextEvent);
    }
  } else if(navTransitioned) {
    untransitionNav();
    setUpTabs();
  }
}

function transitionNav() {
  $(".navbar").addClass("is-transitioned");
  navTransitioned = true;
}

function untransitionNav() {
  $(".navbar").removeClass("is-transitioned");
  navTransitioned = false;
}

function clickCircle() {
  var id = $(this).attr('id').slice(-1);
  setTab(parseInt(id));
}