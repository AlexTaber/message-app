var transferTask = -1;
var transferConvo = -1;

window.onload = function() {
  $(".transfer-icon").on('click', activateTransfer);
  $("#transfer-close").on('click', closeTransfer);
  $(".conversation-wrapper, .notes-wrapper").on('click', selectTransfer);

  //pusher
  if(typeof conversationTokens !== 'undefined') {
    var channel;
    var conversationToken;
    for(var i = 0; i < conversationTokens.length; i++) {
      conversationToken = conversationTokens[i];
      listenForOldTransferedTasks(conversationToken, curConvoToken);
      listenForNewTransferedTasks(conversationToken, curConvoToken);
    }
  }
}

function activateTransfer() {
  var el = $(this).parents(".task-container");
  transferTask = parseInt(el.attr('id').replace("task-", ""));
  $("#transfer-cover").addClass("is-transitioned");
  $("#transfer-header").addClass("is-transitioned");

  var el = $("#mobile-convos");
  $('.mobile-active').removeClass('mobile-active')
  $(el).addClass('mobile-active')
  $('.mobile-target').fadeOut(0);
  $('#current-account').slideUp();
  i = $(el).parent().children().index(el) - 1
  $('.mobile-target').eq(i).fadeIn();
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
  $("#ajax-loader-message").show();

  $.ajax({
    url: "/tasks/" + String(transferTask) + "/transfer",
    method: "PUT",
    data: { conversation_id: transferConvo }
  }).done(function(response){
    //done
    $("#ajax-loader-message").hide();
  });
}

function listenForOldTransferedTasks(conversationToken, curConvoToken) {
  channel = pusher.subscribe('transferOldTask' + String(conversationToken) + String(userId));
  channel.bind('transfer-old-task', function(data) {
    $("#conversation" + String(data.convo_id)).html(data.app_html);
    $("#notes" + String(data.convo_id)).html(data.notes_html);

    if(curConvoToken == data.convo_token) {
      $("#task-" + String(data.task_id)).remove();
      $("#message-" + String(data.message_id)).remove();
    }

    $(".conversation-wrapper, .notes-wrapper").on('click', selectTransfer);
  });
}

function listenForNewTransferedTasks(conversationToken, curConvoToken) {
  channel = pusher.subscribe('transferNewTask' + String(conversationToken) + String(userId));
  channel.bind('transfer-new-task', function(data) {
    $("#conversation" + String(data.convo_id)).html(data.app_html);
    $("#notes" + String(data.convo_id)).html(data.notes_html);

    if(curConvoToken == data.convo_token) {
      if(tasksMode) {
        $(".no-pending-tasks").remove();
        $(".pending-tasks").append(data.task_html);
        updateTaskListeners();
      }
    }

    $(".conversation-wrapper, .notes-wrapper").on('click', selectTransfer);
  });
}