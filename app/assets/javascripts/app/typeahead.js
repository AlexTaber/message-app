$(document).ready(function() {
  if(typeof siteId !== 'undefined') {
    $.ajax({
      url: '/typeahead',
      method: "GET",
      data: {
        site_id: siteId
      }
    }).done(function(response){
      var site_users = response.site_users;

      var substringMatcher = function(users) {
        return function findMatches(q, cb) {
          var matches, substringRegex;

          // an array that will be populated with substring matches
          matches = [];

          // regex used to determine if a string contains the substring `q`
          substrRegex = new RegExp(q, 'i');

          // iterate through the pool of strings and for any string that
          // contains the substring `q`, add it to the `matches` array
          $.each(users, function(i, user) {
            if (substrRegex.test(user.name)) {
              matches.push(user);
            }
          });
          cb(matches);
        };
      };

      $('.typeahead').typeahead({
        hint: true,
        highlight: true,
        minLength: 1
      },
      {
        name: 'site_users',
        displayKey: 'name',
        source: substringMatcher(site_users)
      });

      $('.typeahead').on('typeahead:selected', function (e, datum) {
        $("#user_id").val(datum['id']);
      });
      //end ajax response---
    });
  }
});