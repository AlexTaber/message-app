///APP Header
var canSendMessage = true;
var curNext = 1;

jQuery(document).ready(function($){

    //sidr
  jQuery("#right-menu").sidr({name:"sidr-right", side:"right"})

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
    $('.mobile-target').eq(2).fadeIn();
    $('.mobile-active').removeClass('mobile-active')
    $('#mobile-messages').addClass('mobile-active');
    scrollToBottom();
  }
  if ((!messageUrl && tasksUrl) || (!messageUrl && mobileConvoUrl))  {
    $('.mobile-target').fadeOut(0);
    $('#current-account').slideUp();
    $('.mobile-target').eq(1).fadeIn();
    $('.mobile-active').removeClass('mobile-active')
    $('#mobile-convos').addClass('mobile-active');
  }

  //END PUSHER----------------------

  // User Chevron ------------------
  $('.menu-caret').on('click', function(){
    $(this).toggleClass('rotated');
  });
  $('.project-target').on('click', function(){
    $(this).siblings('.menu-caret').toggleClass('rotated');
  });

  // Send Message-------------------
  $("#av-message-form").submit(sendMessage);
  $("#new_conversation").submit(startConversation);
  //--------------------------------

  //set up message init ajax
  setUpMessageAjaxInit();
  //----------------------

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
$(".mobile-icons i:not(:first-child)").on('click', function(){
  $('.mobile-active').removeClass('mobile-active')
  $(this).addClass('mobile-active')
  $('.mobile-target').fadeOut(0);
  $('#current-account').slideUp();
  i = $(this).parent().children().index(this) - 1
  $('.mobile-target').eq(i).fadeIn();
  if(i == 2) {
    scrollToBottom();
  }
});

//show completed tasks
$('.completed-tasks-btn').on('click', clickTaskButton);

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

$('.activate-modal').click(function(e){
  e.preventDefault();
	var modal_id = $(this).attr('name');
	show_modal(modal_id);
});

$('.close-modal, .close-modal-text').click(function(){
	close_modal();
});

	$('.dismiss').on('click', function(e) {
		e.preventDefault;
		$('.flash').fadeOut();
	});

  //flash messages fade out after 3 sec
	$('.flash').delay(3000).fadeOut();

//Tabs

$('.tab-list li').on('click', function(e){
    e.preventDefault();
    var i = $(this).parent().children().index(this)
  if(!$(this).hasClass('.active-tab')){
      $(".active-tab").removeClass("active-tab");
      $(this).addClass('active-tab')
      $('.tab-content>div').eq(i).addClass('active-tab')
  }
});


// $(".close-new-convo").on('click', function(e){
//   e.preventDefault();
//   $('.new-convo-placeholder').hide();
// });


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

$('#form-wrapper textarea').css('overflow', 'hidden').autogrow()

$('.back-button').on('click', function(){
  $(this).parent().fadeOut(0).prev().fadeIn();
});

});
$(window).on('load',function(){
  $('.new-focus').focus();
});

//Functions
function nextButton(target){
  $(target).parent().parent().fadeOut(0).next().fadeIn();
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
  e.preventDefault();
  if(messageSendable()) {
    canSendMessage = false;
    $("#ajax-loader-message").show();
    $.ajax({
      url: e.target.action,
      method: "POST",
      data: $(e.target).serialize()
    }).done(function(response){
      canSendMessage = true;
      $(".new_message").find("#message_content").val("");
      $('#form-wrapper textarea').css('height', '40px');
      $("#ajax-loader-message").hide();
    });
  }
}

function startConversation(e) {
  e.preventDefault();
  if(newMessageSendable()) {
    canSendMessage = false;
    $("#ajax-loader-message").show();
    $.ajax({
      url: e.target.action,
      method: "POST",
      data: $(e.target).serialize()
    }).done(function(data){
      canSendMessage = true;
      curConvoToken = data.token;
      $("#form-wrapper").html(data.form_html);
      $("#av-message-form").submit(sendMessage);
      enterSubmit('#message_content', '#av-message-form');
      if(tasksMode) {
        $(".no-pending-tasks").remove();
        $(".pending-tasks").append(data.html);
      } else {
        $(".app-view").append(anchorme.js(data.html, { "target":"_blank" }));
      }
      updateTaskListeners();
      subscribeToConvo(data.token, curConvoToken);
      listenForNewTasks(data.token, curConvoToken);
      $(".new_conversation").find("#content").val("");
      $('.new-convo-placeholder').slideUp();
      $('#form-wrapper textarea').css('height', '40px');
      $("#ajax-loader-message").hide();
    });
  }
}

function scrollToBottom() {
  var tar = $(".msg-bx-convo");
  if( tar.length > 0) {
    tar.scrollTop(tar[0].scrollHeight - tar.height())
  }
}

function messageSendable() {
  var content = $(".new_message").find("#message_content").val();
  if(canSendMessage && content != "") {
    return true;
  }
  return false;
}

function newMessageSendable() {
  var content = $(".new_conversation").find("#content").val();
  if(canSendMessage && content != "") {
    return true;
  }
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
          $(".app-view").append(anchorme.js(data.current_user_html, { "target":"_blank" }));
        } else {
          $(".app-view").append(anchorme.js(data.other_user_html, { "target":"_blank" }));
        }
      }

      updateTaskListeners();
      scrollToBottom();
    }

    if(notesMode) {
      $("#notes" + String(data.conversation_id)).html(data.notes_html);
    } else {
      $("#conversation" + String(data.conversation_id)).html(data.app_html);
    }

    if(userId != data.user_id && projectId != data.project_id) {
      $("#project-" + String(data.project_id)).addClass("is-unread-project");
    }
  });
}

function listenForNewConvos() {
  channel = pusher.subscribe('new-conversation' + String(userId));
  channel.bind('new-conversation', function(data){

    if(projectId == data.project_id) {
      var newConvoEl = $(".new-convo-placeholder");

      if(newConvoEl.length) {
        newConvoEl.after(anchorme.js(data.app_html, { "target":"_blank" }));
      } else {
        $(".current-project-data").after(data.app_html);
      }
    }
  });
}

function listenForNewTasks(conversationToken, curConvoToken) {
  channel = pusher.subscribe('task' + String(conversationToken) + String(userId));
  channel.bind('new-task', function(data) {
    if(curConvoToken == data.conversation_token) {
      //if current convo
      if(tasksMode) {
        $("#task-" + String(data.task_id)).replaceWith("");
        updateTasksButton(data.completed_tasks_count, data.deleted);

        if(data.completer_id) {
          $(".completed-tasks").append(data.task_html);
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
  $(".transfer-icon").on('click', activateTransfer);
}

function validateUserData(data, element, submit) {
  $("#ajax-loader-message").show();

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
    $("#ajax-loader-message").hide();
  }.bind(element));
}

function typeaheadAjaxLoader(e) {
  $("#ajax-loader-message").show();
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
  $("#ajax-loader-message").show();

  $.ajax({
    url: $(this).attr("href"),
    method: "PUT"
  }).done(function(count){
    $("#ajax-loader-message").hide();
  });
}

function newModel(e) {
  e.preventDefault();
  e.stopPropagation();
  $("#ajax-loader-message").show();

  $.ajax({
    url: $(this).attr("href"),
    method: "POST"
  }).done(function(response){
    $("#ajax-loader-message").hide();
  });
}

function removeModel(e) {
  e.preventDefault();
  e.stopPropagation();
  $("#ajax-loader-message").show();
  $.ajax({
    url: $(this).attr("href"),
    method: "DELETE"
  }).done(function(response){
    $("#ajax-loader-message").hide();
  });
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
  if ($(".msg-bx-convo").scrollTop() == 0) {
    if(!tasksMode) {
      lazyLoad();
    }
  }
}

function lazyLoad() {
  $("#ajax-loader-message").show();

  $.ajax({
    url: '/lazy_load',
    method: "GET",
    data: { lazy_load: lazyLoadIndex + 1, token: curConvoToken, notes: notesMode }
  }).done(function(response){
    var msgBox = $(".msg-bx-convo");
    $("#ajax-loader-message").hide();

    if (response.length > 0) {
      lazyLoadIndex += 1;
      var originalHeight = msgBox[0].scrollHeight;

      if(notesMode) {
        $(".notes").prepend(response);
      } else {
        $(".msg-bx-convo").prepend(response);
      }

      var heightDifference = msgBox[0].scrollHeight - originalHeight;
      msgBox[0].scrollTop += heightDifference;
      updateTaskListeners();

    } else {
      msgBox.off( "scroll", checkLazyLoad )
    }
  });
}

function clickTaskButton(e) {
  e.preventDefault();
  if($(".completed-tasks-btn span").text() === 'Show') {
    $(".completed-tasks-btn span").text('Hide');
  } else {
    $(".completed-tasks-btn span").text('Show');
  }
  $('.completed-tasks').slideToggle();
}

function setUpMessageAjaxInit() {
  var appView = $(".app-view");

  if(appView.length > 0) {
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
    $(".app-view").html(response);
    $("#ajax-loader-message").hide();
    messagesEvents();
  });
}

function messagesEvents() {
  if(!tasksMode) {
    scrollToBottom();
  }

  //lazy load -----------------------
  setTimeout(function() {
    $(".msg-bx-convo").on('scroll', checkLazyLoad);
  }, 500);
  //---------------------------------

  updateTaskListeners();
}