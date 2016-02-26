///APP Header
var canSendMessage = true;
var curNext = 1;

jQuery(document).ready(function($){
  scrollToBottom();
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
  $('.site-target').on('click', function(){
    $(this).siblings('.menu-caret').toggleClass('rotated');
  });

  // Send Message-------------------
  $("#av-message-form").submit(sendMessage);
  $("#new_conversation").submit(startConversation);
  //--------------------------------

  //Update Tasks-----------------
  $(".uncomplete-task, .complete-task").on('click', updateTask);
  $(".new-task").on('click', newTask);
  $(".remove-task").on('click', removeTask);

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

});

//show completed tasks
$('.completed-tasks-btn').on('click', function(e){
  e.preventDefault();
  if($(".completed-tasks-btn span").text() === 'Show') {
    $(".completed-tasks-btn span").text('Hide');
  } else {
    $(".completed-tasks-btn span").text('Show');
  }
  $('.completed-tasks').slideToggle();
});

//mobile menu tasks
  if($('.convo-links').text() == 'Tasks') {
    $('#mobile-messages').removeClass('fa-check-circle-o');
    $('#mobile-messages').addClass('fa-comment');
  } else {
    $('#mobile-messages').removeClass('fa-comment');
    $('#mobile-messages').addClass('fa-check-circle-o');
  }

///Modal
var window_width = $(window).width();
var window_height = $(window).height();
$('.modal-window').each(function(){
	var modal_height = $(this).outerHeight();
	var modal_width = $(this).outerWidth();
	var top = (window_height-modal_height)/2;
	var left = (window_width-modal_width)/2;
	$(this).css({'top' : top , 'left' : left});
});

$('.activate-modal').click(function(e){
  e.preventDefault();
	var modal_id = $(this).attr('name');
	show_modal(modal_id);
});

$('.close-modal').click(function(){
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
$('.username-next').on('click', function(){
  validateUserData({ user: {
    username: $('#user_username').val()
  } }, this);
});

$('.email-next').on('click', function(){
  validateUserData({ user: {
    email: $('#user_email').val(),
    first_name: $('#user_first_name').val(),
    last_name: $('#user_last_name').val()
  } }, this);
});

$('.password-next').on('click', function(){
  if(!$('#user_password').val()){
    $('#user_password').addClass('signup-warning');
    $('.warning-text').fadeOut(0);
    $(this).prev().before('<p class="warning-text">Please choose a password</p>');
  } else if (!$('#confirm_password').val()){
    $('#confirm_password').addClass('signup-warning');
    $('.warning-text').fadeOut(0);
    $(this).prev().before('<p class="warning-text">Please confirm your password</p>');
  } else if ($('#user_password').val() !== $('#confirm_password').val()){
    $('#confirm_password, #user_password').addClass('signup-warning');
    $('.warning-text').fadeOut(0);
    $(this).prev().before('<p class="warning-text">Your password and confirmatin must match.</p>');
  } else if ($('#user_password').val().length < 8) {
    $('#confirm_password, #user_password').addClass('signup-warning');
    $('.warning-text').fadeOut(0);
    $(this).prev().before('<p class="warning-text">Your password must be at least 8 characters</p>');
  } else {
    nextButton(this)
  }
});

//remove validation warnings when field is not empty
$('.signup input').on('blur', function(){
  if( $(this).val()){
    $(this).removeClass('signup-warning');
    $('.warning-text').fadeOut(0);
  }
});


$('.back-button').on('click', function(){
  $(this).parent().fadeOut(0).prev().fadeIn();
});

});
$(window).on('load',function(){
  $('.new-focus').focus();
});

//Functions
function nextButton(target){
  $(target).parent().fadeOut(0).next().fadeIn();
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
      $(".app-view").append(data.html);
      subscribeToConvo(data.token, curConvoToken);
      $(".new_conversation").find("#content").val("");
      $('.new-convo-placeholder').slideUp();
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
        $(".pending-tasks").prepend(data.task_html);
      } else {
        if(userId == data.user_id) {
          $(".app-view").append(anchorme.js(data.current_user_html, { "target":"_blank" }));
        } else {
          $(".app-view").append(anchorme.js(data.other_user_html, { "target":"_blank" }));
        }
      }

      scrollToBottom();
    }

    $("#conversation" + String(data.conversation_id)).html(data.app_html);
  });
}

function listenForNewConvos() {
  channel = pusher.subscribe('new-conversation' + String(userId));
  channel.bind('new-conversation', function(data){

    if(siteId == data.site_id) {
      var newConvoEl = $(".new-convo-placeholder");

      if(newConvoEl.length) {
        newConvoEl.after(anchorme.js(data.app_html, { "target":"_blank" }));
      } else {
        $(".current-site-data").after(data.app_html);
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

        if(data.completed) {
          $(".completed-tasks").prepend(data.task_html);
        } else {
          $(".pending-tasks").prepend(data.task_html);
        }

        $(".completed-tasks-btn").html(tasksButtonHtml(data.completed_tasks_count));
      } else {
        if(userId == data.user_id) {
          $("#message-" + String(data.message_id)).replaceWith(data.current_user_html);
        } else {
          $("#message-" + String(data.message_id)).replaceWith(data.other_user_html);
        }
      }

      $(".uncomplete-task, .complete-task").on('click', updateTask);
      $(".new-task").on('click', newTask);
      $(".remove-task").on('click', removeTask);
    }
  });
}

function validateUserData(data, element) {
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
      nextButton(element)
    }
    $("#ajax-loader-message").hide();
  }.bind(element));
}

function typeaheadAjaxLoader(e) {
  $("#ajax-loader-message").show();
}

function signInSubmit(e) {
  if(curNext < 4) {
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

function newTask(e) {
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

function removeTask(e) {
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

function tasksButtonHtml(count) {
  return "<span>Show</span> " + String(count) + " Completed Tasks";
}