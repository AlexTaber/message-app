$(document).ready(function() {
  setUpTypeahead();
});

function setUpTypeahead() {
  if(typeof projectId !== 'undefined') {
    $.ajax({
      url: '/typeahead',
      method: "GET",
      data: {
        project_id: projectId,
        convo_id: curConvoId,
        convo_user_ids: convoUserIds
      }
    }).done(function(response){
      var project_users = response.project_users;
      if(typeof project_users === 'undefined') { project_users = [] }

      var substringMatcher = function(users, query) {
        return function findMatches(q, cb) {
          var matches, substringRegex;

          // an array that will be populated with substring matches
          matches = [];

          // regex used to determine if a string contains the substring `q`
          substrRegex = new RegExp(q, 'i');

          // iterate through the pool of strings and for any string that
          // contains the substring `q`, add it to the `matches` array
          $.each(users, function(i, user) {
            var user_full = user.name + "(" +user.username +")";
            if(query == 'name') {
              if (substrRegex.test(user_full)) {
                matches.push(user);
              }
            } else {
              if (substrRegex.test(user_full)) {
                matches.push(user);
              }
            }
          });
          cb(matches);
        };
      };

      $('.convo-typeahead').typeahead({
        hint: false,
        highlight: true,
        minLength: 0,
      },
      {
        name: 'project_users',
        displayKey: 'name',
        limit: 100,
        source: substringMatcher(project_users, 'name'),
                templates: {
          empty: emptyHtml(project_users),
          suggestion: function(data) {
            if (data.image_url === null){
              var name = data.name;
              var first_initial = name.charAt(0);
              return '<p style="margin-bottom:0;"><span class="typeahead-image-container"><span class="profile-pic has-no-pic typeahead-image">' + first_initial + '</span></span>' + data.name + '<br><span class="grey-color">'+ data.username +'</span></p>';
            } else {
              return '<p style="margin-bottom:0;"><span class="typeahead-image-container"><img class="typeahead-image" src="' + data.image_url + '"></span>' + data.name + '<br><span class="grey-color">'+ data.username +'</span></p>';
          }
        }
      }
      });

      $('.convo-typeahead').on('typeahead:select', function (e, datum) {
        $("#user_id").val(datum['id']);
        $('.add-users-typeahead').submit();
      });
      $('.convo-typeahead').on('typeahead:cursorchange', function (e, datum) {
        $("#user_id").val(datum['id']);
      });
      //end ajax response---
    });
  }
}

function removeTypeahead() {
  $('.typeahead-form').typeahead('destroy');
}

function emptyHtml(project_users) {
  if(projectUserIds.length <= 1) {
    return [
      '<div class="empty-message">',
        '<b class="text-center" style="display:block;">There are no users in this project.</b><br> <span style="font-size:80%;"">If you created this project, add some by going to <b>MANAGE USERS</b> under this project\'s name on the left of your dashboard.</span>',
      '</div>'
    ].join('\n')
  } else if(project_users.length == 0) {
    return [
      '<div class="empty-message">',
        '<b class="text-center" style="display:block;">There are no more users to add to this conversation.</b><br> <span style="font-size:80%;"">If you created this project, add them by going to <b>MANAGE USERS</b> under this project\'s name on the left of your dashboard.</span>',
      '</div>'
    ].join('\n')
  } else {
    return [
      '<div class="empty-message">',
        '<b class="text-center" style="display:block;">There are no users by this name in this project.</b><br> <span style="font-size:80%;"">If you created this project, add them by going to <b>MANAGE USERS</b> under this project\'s name on the left of your dashboard.</span>',
      '</div>'
    ].join('\n')
  }
}