var transferTask = -1;
var transferConvo = -1;

window.onload = function() {
  $(".transfer-icon").on('click', activateTransfer);
  $("#transfer-close").on('click', closeTransfer);
  $(".conversation-wrapper, .notes-wrapper").on('click', selectTransfer);
}

function activateTransfer() {
  var el = $(this).parents(".task-container");
  transferTask = parseInt(el.attr('id').replace("task-", ""));
  $("#transfer-cover").addClass("is-transitioned");
  $("#transfer-header").addClass("is-transitioned");
}

function closeTransfer() {
  $("#transfer-cover").removeClass("is-transitioned");
  $("#transfer-header").removeClass("is-transitioned");
  transferTask = -1;
  transferConvo = -1;
}

function selectTransfer(e) {
  if(transferTask != -1) {
    e.preventDefault();
    transferConvo = parseInt($(this).data('convo-id'));
    sendTransfer();
    closeTransfer();
  }
}

function sendTransfer() {
  debugger;
  $.ajax({
    url: "/tasks/" + String(transferTask),
    method: "PUT",
    data: { task: { conversation_id: transferConvo } }
  }).done(function(response){
    console.log(response);
  });
}