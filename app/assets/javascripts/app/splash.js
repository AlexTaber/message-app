var scrollDiv;
var navTransitioned = false;
var canTransition = true;
var curTransition = 0;
var curTransitionEl;
var transitionOffset = $(window).height() * 0.75;

var celebrationTextArr = [
  "Time to Party :)",
  "*danceparty*",
  "Eat Some Cake :)",
  "Happytimes Abound :)",
  "Celebrate With Friends :)",
  "Do a Dance :)",
  "Bask in Your Accomplishments :)"
]
var landingTextArr = [
  "Let's fly to the moon!",
  "Go save the world!",
  "Send me that image!",
  "Can you help me move??",
  "Don't forget to bring cake!"
]
var headerTextArr = [
  "Send Your Team a Message",
  "Mark It as a Task",
  "Complete It!",
  false,
  "Message-Based Task Management"
]
var landingText;
var landingTextEl;
var mainEl;
var landingTextIndex = 0;
var headerTextIndex = 0;
var events = [
  transition1,
  transition2,
  transition3,
  transition4,
  transition5,
  transition6,
  transition7
]
var eventIndex = 0;

window.addEventListener ?
window.addEventListener("load",splashLoad,false) :
window.attachEvent && window.attachEvent("onload",splashLoad);

function splashLoad() {
  var splashPage = $(".landing").length;
  totalTransitions = $(".transitionable").length;

  if(splashPage > 0) {
    setTimeout(function() {
      $("#ajax-loader").fadeOut(500);
      setUpLanding();
      setUpNav();
    }, 200);
  }
};

function setUpNav() {
  scrollDiv = $("#scroll-div");
  scrollDiv.on('scroll', scrollNav);
}

function scrollNav() {
  var top = scrollDiv.scrollTop();

  if(top > 400) {
    if(!navTransitioned) {
      transitionNav();
    }
  } else if(navTransitioned) {
    untransitionNav();
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

function setUpLanding() {
  mainEl = $(".main-object");
  landingTextEl = mainEl.children("p");
  setLandingText();
}

function setLandingText() {
  landingText = landingTextArr[Math.floor(Math.random() * landingTextArr.length)];

  setNextType();
}

function typeLandingText() {

  if(landingTextIndex < landingText.length) {
    var character = landingText[landingTextIndex];

    landingTextEl.append(character);
    setNextType();
  } else {
    setTimeout(function() {
      nextEvent();
    }, 500);
  }

  landingTextIndex += 1;
}

function setNextType() {
  setTimeout(function() {
    typeLandingText();
  }, 150);
}

function nextEvent() {
  events[eventIndex]();

  eventIndex += 1;
}

function transition1() {
  $(".send").addClass("tran1");
  setTimeout(function() {
    $(".send").addClass("tran2");
    $(".send").removeClass("tran1");

    setTimeout(function() {
      nextEvent();
    }, 200);

  }, 200)
}

function transition2() {
  mainEl.addClass("tran1");
  $("#set-1").addClass("tran1");
  nextHeaderText();

  setTimeout(nextEvent, 2000);
}

function transition3() {
  $("#set-1").addClass("tran2");
  setTimeout(function() {
    $("#set-1").removeClass("tran2");

    setTimeout(function() {
      nextEvent();
    }, 200);

  }, 200)
}

function transition4() {
  $("#set-1").removeClass("tran1");
  $("#set-2").addClass("tran1");
  mainEl.addClass("tran2");
  nextHeaderText();

  setTimeout(nextEvent, 2000);
}

function transition5() {
  $("#set-2").addClass("tran2");
  setTimeout(function() {
    $("#set-2").removeClass("tran2");

    setTimeout(function() {
      nextEvent();
    }, 200);

  }, 200)
}

function transition6() {
  mainEl.removeClass("tran2");
  mainEl.addClass("tran3");
  $("#set-2").removeClass("tran1");
  nextHeaderText();

  setTimeout(nextEvent, 3000);
}

function transition7() {
  $(".landing-content").addClass("tran1");
  $(".landing-logo").addClass("tran1");
  nextHeaderText();
}

function nextHeaderText() {
  var textEl = $(".landing-text").children("h1");
  textEl.fadeOut(500);
  setTimeout(function() {
    headerTextIndex += 1;
    var text = headerTextArr[headerTextIndex];

    if(!text) {
      text = getCelebrationText();
    }

    textEl.html(text)
    textEl.fadeIn(800);
  }, 500)
}

function getCelebrationText() {
  return celebrationTextArr[Math.floor(Math.random() * celebrationTextArr.length)];
}
