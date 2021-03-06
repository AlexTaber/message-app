///APP Header
var canSendMessage = true;
var curNext = 1;
var changeConvoBool = true;
var totalMessages = 0;
var completedTasksShow = false;
var totalTransitions;
var invalidFiles = [];
var searchMode = false;
var canSubmitProject = true;
var formWrapper;


jQuery(document).ready(function($){

  //set up settings form
  setUpSettingsForm();

  //typeahead ajax-loader
  $(".typeahead-form").submit(typeaheadAjaxLoader);

  //PUSHER--------------------------
  if(typeof conversationTokens !== 'undefined') {
    var channel;
    var conversationToken;
    for(var i = 0; i < conversationTokens.length; i++) {
      conversationToken = conversationTokens[i];
      subscribeToConvo(conversationToken, curConvoToken);
      listenForNewTasks(conversationToken, curConvoToken);
      listenForNewClaims(conversationToken, curConvoToken);
    }
    listenForNewConvos();
  }

  //if user clicks conversation on mobile

  var messageUrl = window.location.href.indexOf("user_ids") > -1
  var tasksUrl = window.location.href.indexOf("tasks") > -1
  var mobileConvoUrl = window.location.href.indexOf("mobile_conversation") > -1
  var newConversationUrl = window.location.href.indexOf("new_conversation") > -1
  var mediaSize = $('body').width() < 750
  if (( messageUrl || newConversationUrl) && mediaSize) {
    $('.mobile-target').fadeOut(0);
    $('#current-account').slideUp();
    $('.mobile-target').eq(3).fadeIn();
    $('.mobile-active').removeClass('mobile-active')
    $('#mobile-messages').addClass('mobile-active');
    scrollToBottom();
  }
  // if ((!messageUrl && tasksUrl) || (!messageUrl && mobileConvoUrl))  {
  //   $('.mobile-target').fadeOut(0);
  //   $('#current-account').slideUp();
  //   $('.mobile-target').eq(0).fadeIn();
  //   $('.mobile-active').removeClass('mobile-active')
  //   $('#mobile-convos').addClass('mobile-active');
  // }

  //END PUSHER----------------------

  // User Chevron ------------------
  $('.menu-caret').on('click', function(){
    $(this).toggleClass('rotated');
  });
  $('.project-target').on('click', function(){
    $(this).siblings('.menu-caret').toggleClass('rotated');
  });

  //set up transitions
  totalTransitions = $(".transitionable").length;
  if(totalTransitions > 0) {
    setUpTransitions();
  }

  // Send Message-------------------
  $("#av-message-form").submit(sendMessage);
  $("#new_conversation").submit(startConversation);
  //--------------------------------

  //set add/remove user ajax
  setManageUserEvents();

  //set up pricing button
  setUpPricing();

  //set up message init ajax
  setUpMessageAjaxInit();
  //----------------------

  lostConnectionWarning();

  //set up tabs
  tabs();

  //prevent double submit for projects
  preventProjectDoubleSubmit();

  //add user to conversation
  $('.add-user-to-convo').on('click', function(){
    $('.add-focus').focus();
  })
  //----------------

  //manage user edit ----------------
  $('.manage-user-edit').on('click', function(){
    $(this).siblings('span').fadeToggle();
  })
  //enter submit
  enterSubmit('#message_content', '#av-message-form');
  enterSubmit('#content', '#new_conversation');
  //-----------

  //sign-in form
  $(".new_user").keydown(signInSubmit);

	$('#users-account').on('click', function () {
		$('nav#current-account').slideToggle(500);
	});
		dropdowns('#new-message-trigger', '#new-message');
//Accordian
$(".open-accordian").on('click',function() {
  jQuery(this).siblings( ".accordian-content" ).slideToggle(500);
});

//mobile-nav
$(".mobile-icons a").on('click', function(){
  $('.mobile-active').removeClass('mobile-active')
  $(this).addClass('mobile-active')
  $('.mobile-target').fadeOut(0);
  $('#current-account').slideUp();
  i = $(this).parent().children().index(this)
  $('.mobile-target').eq(i).fadeIn();
  if(i == 2) {
    scrollToBottom();
  }
});

//support dropdowns

  jQuery('.drop-list').hide();
  jQuery('.list-div').on('click',function(e){
      e.preventDefault();
      jQuery('.list-div').siblings(".drop-list").slideUp();
      if (jQuery(this).siblings(".drop-list").is(':hidden')) {
        jQuery(this).siblings(".drop-list").slideToggle();
      }
      if (!jQuery(this).children().children(".list-caret").hasClass('fa-caret-up')) {
      jQuery('.fa-caret-up').removeClass('fa-caret-up').addClass('fa-caret-down');
    }
      jQuery(this).children().children(".list-caret").toggleClass("fa-caret-up fa-caret-down");
  });


///Modal
var window_width = $(window).width();
var window_height = $(window).height();

$('.activate-modal').click(activateModal);

$('.close-modal, .close-modal-text').on('click', close_modal);

	$('.dismiss').on('click', function(e) {
		e.preventDefault;
		$('.flash').fadeOut();
	});

  //flash messages fade out after 3 sec
	$('.flash').delay(3000).fadeOut();

// //Tabs

// $('.tab-list li').on('click', function(e){
//     e.preventDefault();
//     var i = $(this).parent().children().index(this)
//   if(!$(this).hasClass('.active-tab')){
//       $(".active-tab").removeClass("active-tab");
//       $(this).addClass('active-tab')
//       $('.tab-content>div').eq(i).addClass('active-tab')
//   }
// });


// $(".close-new-convo").on('click', function(e){
//   e.preventDefault();
//   $('.new-convo-placeholder').hide();
// });

$("#message_files").change(function(){
    attachmentPreview(this);
});

$("#profile-uploader").change(function(){
    readURL(this);
});


//signup-form validation
$('.email-next').on('click', function(e){
  e.preventDefault();
  if(!$('#user_password').val()){
    $('#user_password').addClass('signup-warning');
    $('.warning-text').fadeOut(0);
    $(this).prev().before('<p class="warning-text">Please choose a password</p>');
    return false;
  } else if (!$('#confirm_password').val()){
    $('#confirm_password').addClass('signup-warning');
    $('.warning-text').fadeOut(0);
    $(this).prev().before('<p class="warning-text">Please confirm your password</p>');
    return false;
  } else if ($('#user_password').val() !== $('#confirm_password').val()){
    $('#confirm_password, #user_password').addClass('signup-warning');
    $('.warning-text').fadeOut(0);
    $(this).prev().before('<p class="warning-text">Your password and confirmatin must match.</p>');
    return false;
  } else if ($('#user_password').val().length < 8) {
    $('#confirm_password, #user_password').addClass('signup-warning');
    $('.warning-text').fadeOut(0);
    $(this).prev().before('<p class="warning-text">Your password must be at least 8 characters</p>');
    return false;
  }

  validateUserData({ user: {
    email: $('#user_email').val().toLowerCase(),
    first_name: $('#user_first_name').val(),
    last_name: $('#user_last_name').val()
  } }, this, false);
});


$('.username-next').on('click', function(e){
  e.preventDefault();

  validateUserData({ user: {
    username: $('#user_username').val()
  } }, this, true);
});

//remove validation warnings when field is not empty
$('.signup input').on('blur', function(){
  if( $(this).val()){
    $(this).removeClass('signup-warning');
    $('.warning-text').fadeOut(0);
  }
});

$('.back-button').on('click', function(){
  $(this).parent().parent().parent().fadeOut(0).prev().fadeIn();
});


});
$(window).on('load',function(){
  var newLoad = $('.new-focus');
  if(newLoad.length > 0 && projectId) {
    newLoad.focus();
  }


  //splashpage mobile menu
  $('#mobile-menu-btn').on('click', function(e){
    e.preventDefault();
    $('#mobile-menu').fadeToggle();
    $(this).toggleClass('active');
    $('.mobile-logo-link').toggleClass('active');
  });
  $('#mobile-menu a').on('click', function(e){
    $('#mobile-menu').fadeOut();
    $('#mobile-menu-btn').removeClass('active');
  });



}); // end document ready

//Functions
function tabs(){
  $('.tab-button').on('click', function(e){
    var tab_this = $(this);
    var tar = tab_this.attr('data-target');
    e.preventDefault();
    if(!tab_this.hasClass('is-active')){
      $('.is-active').removeClass('is-active');
      tab_this.addClass('is-active');
      $('.tab-content').hide();
      $('.tab-content[data-target='+tar+']').fadeIn();
    }
  });
}

function activateModal(e) {
  e.preventDefault();
  $('.modal-window').fadeOut(500);
  var modal_id = $(this).attr('name');
  show_modal(modal_id);
}

function nextButton(target){
  $(target).parent().parent().parent().fadeOut(0).next().fadeIn();
  curNext += 1;
}

function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {
            $('#img-input').fadeIn().attr('src', e.target.result);
        }

        reader.readAsDataURL(input.files[0]);
    }
}
function dropdowns(clicked, target){
  $(clicked).on('click',function(){
      $(target).slideToggle();
      $(this).toggleClass('');
  });
}
function close_modal(){
	$('.mask').fadeOut(500);
	$('.modal-window').fadeOut(500);
}
function show_modal(modal_id){
	$('.mask').css({ 'display' : 'block', opacity : 0});
	$('.mask').fadeTo(500,0.8);
	$('#'+modal_id).fadeIn(500);
}

function showAjaxErrorModal() {
  $("#ajax-loader-message").hide();
  $("#ajax-loader").hide();
  show_modal('ajax-error');
}

function enterSubmit(input, form) {
  $(input).keypress(function(event) {
    if (event.which == 13) {
      if(event.shiftKey) {
        addNewLine(form);
      } else {
        event.preventDefault();
        $(form).submit();
      }
    }
  });
}
function addNewLine(form) {
  var tar = $(form).find("textarea");
  var value = tar.val();
  tar.val(value);
}

function sendMessage(e) {
  var formData = new FormData($(e.target)[0]);

  formData.append("invalid_files", invalidFiles.join(","));

  e.preventDefault();
  if(messageSendable()) {
    canSendMessage = false;
    $("#ajax-loader").show();
    $.ajax({
      url: e.target.action,
      method: "POST",
      data: formData,
      processData: false,  // tell jQuery not to process the data
      contentType: false,  // tell jQuery not to set contentType
    }).done(function(response){
      //send message events called from pusher event
    }).fail(function() {
      showAjaxErrorModal();
    });
  }
}

function sendMessageEvents() {
  canSendMessage = true;
  $(".new_message").find("#message_content").val("");
  $('#form-wrapper textarea').css('height', '40px');
  $("#ajax-loader").hide();
  $(".attachments-preview").html("");
  resetFormColor();
}

function startConversation(e) {
  e.preventDefault();
  var formData = new FormData($(e.target)[0]);

  formData.append("invalid_files", invalidFiles.join(","));

  if(newMessageSendable()) {
    canSendMessage = false;
    $("#ajax-loader").show();
    $.ajax({
      url: e.target.action,
      method: "POST",
      data: formData,
      processData: false,  // tell jQuery not to process the data
      contentType: false  // tell jQuery not to set contentType
    }).done(function(data){
      canSendMessage = true;
      curConvoToken = data.token;
      $("#form-wrapper").html(data.form_html);
      $("#form-wrapper").append("<div class='attachments-preview'></div>")
      $("#av-message-form").submit(sendMessage);
      enterSubmit('#message_content', '#av-message-form');
      if(tasksMode) {
        $(".no-pending-tasks").remove();
        $(".pending-tasks").append(data.html);
      } else {
        $(".app-view, .mb-view").append(anchorme.js(data.html, { "target":"_blank" }));
      }
      updateTaskListeners();
      subscribeToConvo(data.token, curConvoToken);
      listenForNewTasks(data.token, curConvoToken);
      $(".new_conversation").find("#content").val("");
      $('.new-convo-placeholder').slideUp();
      $('#form-wrapper textarea').css('height', '40px');
      $("#ajax-loader").hide();
      totalMessages += 1;
    }).fail(function() {
      showAjaxErrorModal();
    });;
  }
}

function scrollToBottom() {
  var tar = $(".msg-bx-convo");
  if( tar.length > 0) {
    tar.scrollTop(tar[0].scrollHeight - tar.height())
  }
}

function scrollToTop() {
  var tar = $(".msg-bx-convo");
  tar.scrollTop(0);
}

function messageSendable() {
  var content = $(".new_message").find("#message_content").val();
  if(canSendMessage && content != "") { return true; }
  if($("#message_files")[0].files.length > 0) { return true; }
  return false;
}

function newMessageSendable() {
  var content = $(".new_conversation").find("#content").val();
  if(canSendMessage && content != "") { return true; }
  if($("#message_files")[0].files.length > 0) { return true; }
  return false;
}

function subscribeToConvo(conversationToken, curConvoToken) {
  channel = pusher.subscribe('conversation' + String(conversationToken) + String(userId));
  channel.bind('new-message', function(data) {
    if(curConvoToken == data.conversation_token) {
      //if the message is from the current conversation
      if(tasksMode) {
        $(".no-pending-tasks").remove();
        $(".pending-tasks").append(data.task_html);
      } else if(notesMode) {
        $(".no-note").remove();
        $(".notes").append(data.note_html);
      } else {
        if(userId == data.user_id) {
          $(".app-view, .mb-view").append(anchorme.js(data.current_user_html, { "target":"_blank" }));
        } else {
          $(".app-view, .mb-view").append(anchorme.js(data.other_user_html, { "target":"_blank" }));
        }
      }

      //remove ajax loader if message user == current user
      if(userId == data.user_id) {
        sendMessageEvents();
      }

      if(!tasksMode) {
        scrollToBottom();
      }

      totalMessages += 1;
    }

    if(data.project_id == projectId) {
      if(notesMode) {
        $("#notes" + String(data.conversation_id)).html(data.notes_html);
      } else {
        //target is the targeted conversation card
        var target = $("#conversation" + String(data.conversation_id));
        if(target.length > 0) {
          //check if current convo
          var isCurConvo = target.find(".message-item").hasClass("msg-item-current");
          //update targets html
          target.html(data.app_html);
          //update if currentConvo
          if(isCurConvo) {
            target.find(".message-item").addClass("msg-item-current");
          }
          //copy targets new html
          var targetHtml = target[0].outerHTML;
          //remove target
          target.remove();
          //prepend copied html to the top of the conversations section
          $(".conversations-wrapper").prepend(targetHtml);
        }
      }
    }

    if(userId != data.user_id) {
      updateTitle(1);

      if(projectId != data.project_id) {
        $("#project-" + String(data.project_id)).addClass("is-unread-project");
      }
    }

    messagesEvents();
  });
}

function listenForNewConvos() {
  channel = pusher.subscribe('new-conversation' + String(userId));
  channel.bind('new-conversation', function(data){

    if(projectId == data.project_id) {
      $(".conversations-wrapper").prepend(
        "<div class='conversation-wrapper' id='conversation" + String(data.conversation_id) + "' data-convo-id='" + String(data.conversation_id) + "' data-convo-token='" + String(data.conversation_token) + "'>"
        + data.app_html +
        "</div>"
      );
    }

    //update title if conversation not started by current user
    if(data.user_id != userId) { updateTitle(1); }
  });
}

function listenForNewTasks(conversationToken, curConvoToken) {
  channel = pusher.subscribe('task' + String(conversationToken) + String(userId));
  channel.bind('new-task', function(data) {
    if(curConvoToken == data.conversation_token) {
      //if current convo
      if(searchMode) {
        $("#task-" + String(data.task_id)).replaceWith(data.task_html);
      } else if(tasksMode) {
        $("#task-" + String(data.task_id)).replaceWith("");
        updateTasksButton(data.completed_tasks_count, data.deleted);

        if(data.completer_id) {
          $(".completed-tasks").prepend(data.task_html);
        } else {
          $(".no-pending-tasks").remove();
          $(".pending-tasks").append(data.task_html);
        }
      } else if(notesMode) {
        $("#note-" + String(data.message_id)).replaceWith(data.note_html);
      } else {
        if(userId == data.user_id) {
          $("#message-" + String(data.message_id)).replaceWith(data.current_user_html);
        } else {
          $("#message-" + String(data.message_id)).replaceWith(data.other_user_html);
        }
      }

      updateTaskListeners(data.completed_tasks_count);

      if(notesMode) {
        $("#notes" + String(data.conversation_id)).html(data.notes_html);
      } else {
        $("#conversation" + String(data.conversation_id)).html(data.app_html);
      }
    }
  });
}

function listenForNewClaims(conversationToken, curConvoToken) {
  channel = pusher.subscribe('claim' + String(conversationToken) + String(userId));
  channel.bind('new-claim', function(data) {
    if(curConvoToken == data.conversation_token) {
      //if current convo
      if(tasksMode) {
        $("#task-" + String(data.task_id)).replaceWith(data.task_html);
        updateTaskListeners();
      }
    }
  });
}

function updateTaskListeners() {
  $(".uncomplete-task, .complete-task").off('click').on('click', updateTask);
  $(".new-model").off('click').on('click', newModel);
  $(".remove-model").off('click').on('click', removeModel);
  $(".transfer-icon").off('click').on('click', activateTransfer);
  $(".remove-notes").off('click').on('click', removeNote);
  //mobile show messages
  $(".conversation-wrapper, .notes-wrapper, .new-convo-placeholder").off('click', showMessageCenter).on('click', showMessageCenter);
  //preview attachments
  $("#message_files").change(function(){
    attachmentPreview(this);
  });
  //search
  $("#search-show").off('click',showSearch).on('click', showSearch);
  $(".search-hide").off('click',hideSearch).on('click', hideSearch);
  $("#search-form").off('click',sendQuery).on('submit', sendQuery);
  //autogrow
  $('#form-wrapper textarea').css('overflow', 'hidden').autogrow();
  $('#form-wrapper textarea').off('focus').on('focus', removeUnreadConvo);
  setUpFormColor();
}

function validateUserData(data, element, submit) {
  $("#ajax-loader").show();

  $.ajax({
    url: "/validate",
    method: "GET",
    data: data
  }).done(function(response){
    if(response.error) {
      $('#user_' + String(response.attribute)).addClass('signup-warning');
      $('.warning-text').fadeOut(0);
      $(element).before("<p class='warning-text'>" + response.message + "</p>");
    } else {
      if(submit) {
        $('.new_user').submit();
      } else {
        nextButton(element);
      }
    }
    $("#ajax-loader").hide();
  }.bind(element));
}

function typeaheadAjaxLoader(e) {
  $("#ajax-loader").show();
}

function signInSubmit(e) {
  if(curNext < 3) {
    if(e.keyCode == 13) {
      var target = $("#next-" + String(curNext));
      e.preventDefault();

      target.click();
    }
  }
}

function updateTask(e) {
  e.preventDefault();
  e.stopPropagation();
  $("#ajax-loader").show();

  $.ajax({
    url: $(this).attr("href"),
    method: "PUT"
  }).done(function(count){
    $("#ajax-loader").hide();
  }).fail(function() {
    showAjaxErrorModal();
  });;
}

function newModel(e) {
  e.preventDefault();
  e.stopPropagation();
  $("#ajax-loader").show();

  $.ajax({
    url: $(this).attr("href"),
    method: "POST"
  }).done(function(response){
    $("#ajax-loader").hide();
  }).fail(function() {
    showAjaxErrorModal();
  });;
}

function removeModel(e) {
  e.preventDefault();
  e.stopPropagation();
  $("#ajax-loader").show();
  $.ajax({
    url: $(this).attr("href"),
    method: "DELETE"
  }).done(function(response){
    $("#ajax-loader").hide();

    if(typeof response != "string") {
      //replace notes wrapper
      $(".notes-wrapper").html(response.html);
    }
  }).fail(function() {
    showAjaxErrorModal();
  });;
}

function removeNote(e) {
  removeModel.bind(this, e)();

  $(this).parents('.note').remove();
}

function updateTasksButton(completedTasksCount, deleted) {
  var button = $(".completed-tasks-btn");

  if(button.length > 0) {
    if(typeof completedTasksCount === 'undefined') {
      button.remove();
      $(".completed-tasks").remove();
    } else {
      button.html(tasksButtonHtml(completedTasksCount));
    }
  } else if(!deleted) {
    $(".pending-tasks").after("<h5 class='text-center'><a href='#' class='completed-tasks-btn'><span>Show</span> 1 Completed Tasks</a></h5><div class='completed-tasks'></div>");
    $('.completed-tasks-btn').on('click', clickTaskButton);
  }
}

function tasksButtonHtml(count) {
  return "<span>Show</span> " + String(count) + " Completed Tasks";
}

function checkLazyLoad() {
  if(changeConvoBool) {
    if ($(".msg-bx-convo").scrollTop() <= 0) {
      if(!tasksMode) {
        lazyLoad();
      }
    }
  }
}

function checkTasksLazyLoad() {
  if(changeConvoBool) {
    var msgBox = $(".msg-bx-convo");
    var checkedScroll = msgBox[0].scrollHeight - msgBox.height() - 120;
    if (msgBox.scrollTop() >= checkedScroll) {
      if(tasksMode && completedTasksShow) {
        lazyLoad();
      }
    }
  }
}

function lazyLoad() {
  $("#ajax-loader-message").show();
  changeConvoBool = false;

  $.ajax({
    url: '/lazy_load',
    method: "GET",
    data: { lazy_load: lazyLoadIndex + 1, offset: totalMessages, token: curConvoToken, notes: notesMode, tasks: tasksMode }
  }).done(function(response){
    var msgBox = $(".msg-bx-convo");
    changeConvoBool = true;
    $("#ajax-loader-message").hide();

    if (response.length > 0) {
      lazyLoadIndex += 1;
      var originalHeight = msgBox[0].scrollHeight;

      if(tasksMode) {
        $(".completed-tasks").append(response);
      } else if(notesMode) {
        $(".notes").prepend(response);
      } else {
        $(".msg-bx-convo").prepend(response);
      }

      if(!tasksMode) {
        var heightDifference = msgBox[0].scrollHeight - originalHeight;
        msgBox[0].scrollTop += heightDifference;
      }
      updateTaskListeners();

    } else {
      disableLazyLoad(msgBox);
    }
  }).fail(function() {
    showAjaxErrorModal();
  });;
}

function disableLazyLoad(msgBox) {
  msgBox.off( "scroll", checkLazyLoad )
  msgBox.off( "scroll", checkTasksLazyLoad )
}

function clickTaskButton(e) {
  e.preventDefault();
  if($(".completed-tasks-btn span").text() === 'Show') {
    $(".completed-tasks-btn span").text('Hide');
  } else {
    $(".completed-tasks-btn span").text('Show');
  }
  $('.completed-tasks').slideToggle();
  completedTasksShow = !completedTasksShow;
}

function setUpMessageAjaxInit() {
  if(projectId !== null) {
    sendMessageAjaxInit();
  }
}

function sendMessageAjaxInit() {
  $("#ajax-loader-message").show();

  $.ajax({
    url: '/app-messages',
    method: "GET",
    data: {
      conversation_token: curConvoToken,
      project_id: projectId,
      tasks: tasksMode,
      notes: notesMode,
      lazy_load: lazyLoadIndex
    }
  }).done(function(response){
    $(".app-view, .mb-view").html(response);
    $("#ajax-loader-message").hide();
    messagesEvents();
  }).fail(function() {
    showAjaxErrorModal();
  });;
}

function messagesEvents() {
  if(!tasksMode) {
    scrollToBottom();
  }

  //lazy load -----------------------
  setTimeout(function() {
    if(tasksMode) {
      $(".msg-bx-convo").off('scroll').on('scroll', checkTasksLazyLoad);
    } else {
      $(".msg-bx-convo").off('scroll').on('scroll', checkLazyLoad);
    }
  }, 500);
  //---------------------------------

  updateTaskListeners();

  //toggle tasks
  if(curConvoToken !== null) {
    $(".convo-links").off('click').on('click', toggleTasks);
  }

  //listen for change convo
  $(".conversation-wrapper, .notes-wrapper").off('click', changeConvo).on('click', changeConvo);

  //show completed tasks
  $('.completed-tasks-btn').off('click').on('click', clickTaskButton);
}

function toggleTasks(e) {
  e.preventDefault();
  tasksMode = !tasksMode;
  lazyLoadIndex = 0;
  completedTasksShow = false;
  var el = $("#switch-wrapper");
  var str = notesMode ? "Notes" : "Conversation";
  var formString = tasksMode ? "task" : "message";

  if(tasksMode) {
    el.html("<a class='convo-links'>View " + str + "</a> | Tasks");
    $("#message_conversation_id").append("<input type='hidden' name='tasks' id='tasks' value='true'>");

    $("#message_content").attr("placeholder", "Type " + formString + " here...");
  } else {
    el.html(str + " | <a class='convo-links'>View Tasks</a>");
    $("#tasks").remove();
    $("#message_content").attr("placeholder", "Type message here...");
  }

  sendMessageAjaxInit();
}

function changeConvo(e) {
  e.preventDefault();

  if(changeConvoBool) {

    var el = $(this);
    var convoId = el.data('convo-id');
    var convoToken = el.data('convo-token');
    var oldConvoToken = curConvoToken;

    if(el.attr("class") == "notes-wrapper") {
      notesMode = true;
    } else {
      notesMode = false;
    }

    checkForUnreadConvo(convoId);

    if(canChangeConvo(convoId, convoToken, oldConvoToken)) {
      $(".msg-item-current").removeClass("msg-item-current");
      var newMsgItem = el.find(".message-item");

      newMsgItem.addClass("msg-item-current");
      if(newMsgItem.hasClass("is-unread-convo")) {
        newMsgItem.removeClass("is-unread-convo");
        updateTitle(-1);

        if($("is-unread-convo").length == 0) {
          $("is-unread-project").removeClass("is-unread-project");
        }
      }

      //pusher------
      updatePusherListeners(convoToken, oldConvoToken);

      lazyLoadIndex = 0;
      totalMessages = 0;
      curConvoToken = convoToken;
      curConvoId = convoId;

      $(".new-convo-placeholder").slideUp(500);
      updateReadMessages(convoId);

      $(".app-view").html("");
      $("#ajax-loader-message").show();

      changeConvoBool = false;
      completedTasksShow = false;

      $.ajax({
        url: '/conversations/' + convoId,
        method: "GET",
        data: {
          project_id: projectId,
          tasks: tasksMode,
          notes: notesMode
        }
      }).done(function(data){
        $(".message-center").html(data.message_center);
        $(".app-view").html(data.app_messages);
        $("#ajax-loader-message").hide();
        messagesEvents();
        changeConvoListeners();
        setUpTypeahead();
        changeConvoBool = true;
        searchMode = false;
      }).fail(function() {
        showAjaxErrorModal();
      });;
    }
  }
}

function canChangeConvo(convoId, convoToken, oldConvoToken) {
  return typeof convoId !== undefined && (convoToken != oldConvoToken || searchMode);
}

function checkForUnreadConvo(convo_id) {
  var target = $(".is-unread-convo");

  if(target.length > 0) {
    var parent = target.parents('.conversation-wrapper');

    if(parent.data('convo-id') == convo_id) {
      target.removeClass('is-unread-convo');
    }
  }
}

function updatePusherListeners(convoToken, oldConvoToken) {
  //pusher------
  pusher.unsubscribe('conversation' + String(oldConvoToken) + String(userId));
  pusher.unsubscribe('conversation' + String(convoToken) + String(userId));
  pusher.unsubscribe('task' + String(oldConvoToken) + String(userId));
  pusher.unsubscribe('task' + String(convoToken) + String(userId));
  pusher.unsubscribe('claim' + String(oldConvoToken) + String(userId));
  pusher.unsubscribe('claim' + String(convoToken) + String(userId));
  pusher.unsubscribe('transferOldTask' + String(oldConvoToken) + String(userId));
  pusher.unsubscribe('transferOldTask' + String(convoToken) + String(userId));
  pusher.unsubscribe('transferNewTask' + String(oldConvoToken) + String(userId));
  pusher.unsubscribe('transferNewTask' + String(convoToken) + String(userId));
  subscribeToConvo(oldConvoToken, convoToken);
  subscribeToConvo(convoToken, convoToken);
  listenForNewTasks(oldConvoToken, convoToken);
  listenForNewTasks(convoToken, convoToken);
  listenForNewClaims(oldConvoToken, convoToken);
  listenForNewClaims(convoToken, convoToken);
  listenForOldTransferedTasks(oldConvoToken, convoToken);
  listenForOldTransferedTasks(convoToken, convoToken);
  listenForNewTransferedTasks(oldConvoToken, convoToken);
  listenForNewTransferedTasks(convoToken, convoToken);
  //-----------
}

function changeConvoListeners() {
  $(".typeahead-form").off('submit', typeaheadAjaxLoader).on('submit', typeaheadAjaxLoader);
  $("#av-message-form").off('submit').submit(sendMessage);
  $("#new_conversation").off('submit').submit(startConversation);
  enterSubmit('#message_content', '#av-message-form');
  enterSubmit('#content', '#new_conversation');
}

function updateReadMessages(convoId) {
  $.ajax({
    url: 'read-messages',
    method: "POST",
    data: {
      id: convoId
    }
  })
}

function showMessageCenter() {
  $('.mobile-target').eq(1).hide();
  $('.mobile-target').eq(3).show();
  $('.mobile-active').removeClass('mobile-active')
}

function removeModelMU(e) {
  e.preventDefault();
  e.stopPropagation();

  $("#ajax-loader").show();

  $.ajax({
    url: $(this).attr("href"),
    method: "DELETE"
  }).done(function(response){
    $("#ajax-loader").hide();

    $("#manage-users").replaceWith(response);
    removeTypeahead();
    setUpTypeahead();
    show_modal('manage-users');
    $('.close-modal, .close-modal-text').on('click', close_modal);
    $('.activate-modal').off('click').click(activateModal);
    setManageUserEvents();
  }).fail(function() {
    showAjaxErrorModal();
  });;
}

function addUser(e) {
  e.preventDefault();
  e.stopPropagation();

  if(validateInviteEmail()) {

    $("#ajax-loader").show();

    $.ajax({
      url: $(this).attr("action"),
      method: "POST",
      data: $(this).serialize()
    }).done(function(response){
      $("#ajax-loader").hide();

      $("#manage-users").replaceWith(response);
      removeTypeahead();
      setUpTypeahead();
      show_modal('manage-users');
      $('.close-modal, .close-modal-text').on('click', close_modal);
      $('.activate-modal').off('click').click(activateModal);
      setManageUserEvents();
    }).fail(function() {
      showAjaxErrorModal();
    });;
  } else {
    invalidInviteEmail();
  }
}

function setManageUserEvents() {
  //remove user ajax
  $(".remove-model-mu").off('click').on('click', removeModelMU);

  //add user ajax
  $("#new_invite").off('submit', addUser).on('submit', addUser);
}
function lostConnectionWarning(){
  // Update the online status icon based on connectivity
  window.addEventListener('online',  updateIndicator);
  window.addEventListener('offline', updateIndicator);
  updateIndicator();
}

function updateIndicator() {
  if(!navigator.onLine) {
    $('.home-logo').after('<span class="connection-warning">Connection Lost</span>');
  } else {
    $('.connection-warning').hide();
  }
}

function setUpTransitions() {
  scrollDiv = $("#scroll-div");
  scrollDiv.on('scroll', scrollTransitions);
  curTransitionEl = $("#transition-" + String(curTransition));
  scrollTransitions();
}

function scrollTransitions() {
  var top = curTransitionEl.offset().top;

  if(top < transitionOffset) {
    transitionElement(curTransitionEl);
    setNextTransition();
  }
}

function transitionElement(el) {
  el.addClass("is-transitioned");
}

function setNextTransition() {
  curTransition += 1;

  curTransitionEl = $("#transition-" + String(curTransition));
  scrollDiv.off('scroll', scrollTransitions);

  if(curTransition < totalTransitions) {
    setTimeout(function() {
      setUpTransitions();
    }, 50);
  }
}

function attachmentPreview(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();

    reader.onload = function (input, e) {
      invalidFiles = [];
      var files = input.files;
      drawAttPreview(files);

    }.bind(this, input);

    reader.readAsDataURL(input.files[0]);
  }
}

function drawAttPreview(files) {
  var target = $(".attachments-preview");
  target.html("");

  for(var i = 0; i < files.length; i++) {
    target.append("<p class='att-preview' id='att-preview-" + String(i) + "' data-index='" + String(i) + "'>" + files[i].name + " <i class='fa fa-times'></i></p>");
  }

  $(".att-preview").children("i").on('click', removeAttPreview);
}

function removeAttPreview() {
  var index = parseInt($(this).parent("p").data("index"));

  invalidFiles.push(index);
  $('#att-preview-' + String(index)).remove();
}

function showSearch() {
  var input = $("#search-input");
  input.addClass("is-transitioned");
  input.focus();
  $("#search-show").addClass("is-transitioned");
  $("#search-hide").addClass("is-transitioned");
  $("#search-form").addClass("is-transitioned");
  $("#switch-wrapper").addClass("is-transitioned");

  if(tasksMode) {
    input.attr("placeholder", "Search Tasks");
  } else {
    input.attr("placeholder", "Search Conversation");
  }
}

function hideSearch() {
  searchMode = false;
  $("#search-input").removeClass("is-transitioned");
  $("#search-show").removeClass("is-transitioned");
  $("#search-hide").removeClass("is-transitioned");
  $("#search-form").removeClass("is-transitioned");
  $("#switch-wrapper").removeClass("is-transitioned");
  $("#form-wrapper").show();

  sendMessageAjaxInit();
}

function sendQuery(e) {
  e.preventDefault();

  $("#ajax-loader-message").show();

  $.ajax({
    url: "/search",
    method: "GET",
    data: {
      query: $("#search-input").val(),
      tasks: tasksMode,
      token: curConvoToken
    }
  }).done(function(response){
    //turn on search mode
    searchMode = true;

    //append response to view
    $(".app-view, .mb-view").html(response);

    //hid ajax loader
    $("#ajax-loader-message").hide();

    //hide forms
    $("#form-wrapper").hide();

    //disable lazy load
    var msgBox = $(".msg-bx-convo");
    disableLazyLoad(msgBox);

    //update listeners
    updateTaskListeners();

    //scroll to top
    scrollToTop();

    //reset search input text
    $("#search-input").val("");
  }).fail(function() {
    showAjaxErrorModal();
  });;
}

function updateTitle(added_number) {
  var prev_number, new_number;
  var title = $("title");
  var matches = title.html().trim().match(/\(([^\)]+)\)/);

  if(matches !== null) {
    var prev_number = parseInt(matches[1]);
    var new_number = prev_number + added_number
  } else {
    new_number = added_number;
  }

  if(new_number > 0) {
    title.html("(" + String(new_number) + ") New Message | Evia");
  } else {
    title.html("Evia");
  }
}

function removeUnreadConvo () {
  var curConvo = $(".msg-item-current");

  if(curConvo.length > 0) {
    curConvoWrapper = curConvo.parents(".conversation-wrapper");
    var curToken = curConvoWrapper.data("convo-token");
    var convoId = curConvoWrapper.data("convo-id");

    if(curToken === curConvoToken) {
      curConvo.removeClass("is-unread-convo");
      updateReadMessages(convoId);
      updateTitle(-1);
    }
  }
}

function validateInviteEmail() {
  var email = $("#invite_email").val();

  if(!validateEmail(email)) {
    invalidInviteEmail();
    return false
  }

  return true
}

function invalidInviteEmail() {
  $("#invite-notice").html("Invalid Email");
}

function validateEmail(email) {
  var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

function setUpSettingsForm() {
  $("#setting_email_notifications").change(toggleInactiveTimeField);
}

function toggleInactiveTimeField() {
  var form = $("#setting_email_notifications");

  if(form.val() == 'false') {
    $("#inactive-time-field").removeClass('is-transitioned');
  } else {
    $("#inactive-time-field").addClass('is-transitioned');
  }
}

function preventProjectDoubleSubmit() {
  $("#new_project").submit(function(e) {

    if(canSubmitProject) {
      canSubmitProject = false;
      $("#ajax-loader").show();
    } else {
      e.preventDefault();
    }
  })
}

function setUpFormColor() {
  $("#message_content")[0].removeEventListener("keyup", changeFormColor);
  $("#message_content")[0].addEventListener("keyup", changeFormColor);
}

function changeFormColor() {
  var length = $(this).val().length;
  var maxLength = 40;
  var firstColor = "f2f6f9";
  var lastColor = "cecee4";

  var newColor = mix(firstColor, lastColor, 100 - (Math.min(1, length / maxLength) * 100));

  $("#form-wrapper").css("background", newColor);
}

function resetFormColor() {
  $("#form-wrapper").css("background", '#f2f6f9');
}

var mix = function(color_1, color_2, weight) {
  function d2h(d) { return d.toString(16); }  // convert a decimal value to hex
  function h2d(h) { return parseInt(h, 16); } // convert a hex value to decimal

  weight = (typeof(weight) !== 'undefined') ? weight : 50; // set the weight to 50%, if that argument is omitted

  var color = "#";

  for(var i = 0; i <= 5; i += 2) { // loop through each of the 3 hex pairs—red, green, and blue
    var v1 = h2d(color_1.substr(i, 2)), // extract the current pairs
        v2 = h2d(color_2.substr(i, 2)),

        // combine the current pairs from each source color, according to the specified weight
        val = d2h(Math.floor(v2 + (v1 - v2) * (weight / 100.0)));

    while(val.length < 2) { val = '0' + val; } // prepend a '0' if val results in a single digit

    color += val; // concatenate val to our new color string
  }

  return color; // PROFIT!
};