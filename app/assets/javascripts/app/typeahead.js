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
        displayKey: 'typeahead',
        source: substringMatcher(project_users, 'name')
      });

      $('.project-typeahead').typeahead({
        hint: false,
        highlight: true,
        minLength: 1,
      },
      {
        name: 'all_users',
        displayKey: 'typeahead',
        source: substringMatcher(all_users, 'username')
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