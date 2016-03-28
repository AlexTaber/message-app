$(document).ready(function() {
  if(typeof projectId !== 'undefined') {
    $.ajax({
      url: '/typeahead',
      method: "GET",
      data: {
        project_id: projectId
      }
    }).done(function(response){
      var project_users = response.project_users;
      var all_users = response.all_users;
      var all_projects = response.all_projects;
      console.log(response);

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
        minLength: 1,
      },
      {
        name: 'project_users',
        displayKey: 'name',
        source: substringMatcher(project_users, 'name'),
                templates: {
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

      $('.project-typeahead').typeahead({
        hint: false,
        highlight: true,
        minLength: 1,
      },
      {
        name: 'all_users',
        displayKey: 'typeahead',
        source: substringMatcher(all_users, 'username'),
        templates: {
          suggestion: function(data) {
            if (data.image_url == null){
              var name = data.name;
              var first_initial = name.charAt(0);
              return '<p style="margin-bottom:0;"><span class="typeahead-image-container"><span class="profile-pic has-no-pic typeahead-image">' + first_initial + '</span></span>' + data.name + '<br><span class="grey-color">'+ data.username +'</span></p>';
            } else {
              return '<p style="margin-bottom:0;"><span class="typeahead-image-container"><img class="typeahead-image" src="' + data.image_url + '"></span>' + data.name + '<br><span class="grey-color">'+ data.username +'</span></p>';
          }
        }
      },

      });

      $('.request-typeahead').typeahead({
        hint: false,
        highlight: true,
        minLength: 1,
      },
      {
        name: 'all_projects',
        displayKey: 'name',
        source: substringMatcher(all_projects, 'name')
      });

      $('.convo-typeahead').on('typeahead:select', function (e, datum) {
        $("#user_id").val(datum['id']);
        $('.typeahead-form').submit();
      });
      $('.convo-typeahead').on('typeahead:cursorchange', function (e, datum) {
        $("#user_id").val(datum['id']);
      });

      $('.project-typeahead').on('typeahead:select', function (e, datum) {
        $("#add-user-id").val(datum['id']);
        $('#project-typeahead').submit();
      });
      $('.project-typeahead').on('typeahead:cursorchange', function (e, datum) {
        $("#add-user-id").val(datum['id']);
      });

      $('.request-typeahead').on('typeahead:select', function (e, datum) {
        $("#request_project_id").val(datum['id']);
        $('#request-typeahead').submit();
      });
      $('.request-typeahead').on('typeahead:cursorchange', function (e, datum) {
        $("#request_project_id").val(datum['id']);
      });
      //end ajax response---
    });
  }
});