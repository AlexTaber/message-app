$(document).ready(function() {
  var states = [
    { name: 'Alabama' },
    { name: 'Alaska' },
    { name: 'Arizona' },
    { name: 'Arkansas' },
    { name: 'California' },
    { name: 'Colorado' },
    { name: 'Connecticut' },
    { name: 'Delaware' },
    { name: 'Florida' },
    { name: 'Georgia' },
    { name: 'Hawaii' },
    { name: 'Idaho' },
    { name: 'Illinois' },
    { name: 'Indiana' },
    { name: 'Iowa' },
    { name: 'Kansas' },
    { name: 'Kentucky' },
    { name: 'Louisiana' },
    { name: 'Maine' },
    { name: 'Maryland' },
    { name: 'Massachusetts' },
    { name: 'Michigan' },
    { name: 'Minnesota' },
    { name: 'Mississippi' },
    { name: 'Missouri' },
    { name: 'Montana' },
    { name: 'Nebraska' },
    { name: 'Nevada' },
    { name: 'NewHampshire' },
    { name: 'NewJersey' },
    { name: 'NewMexico' },
    { name: 'NewYork' },
    { name: 'NorthCarolina' },
    { name: 'NorthDakota' },
    { name: 'Ohio' },
    { name: 'Oklahoma' },
    { name: 'Oregon' },
    { name: 'Pennsylvania' },
    { name: 'RhodeIsland' },
    { name: 'SouthCarolina' },
    { name: 'SouthDakota' },
    { name: 'Tennessee' },
    { name: 'Texas' },
    { name: 'Utah' },
    { name: 'Vermont' },
    { name: 'Virginia' },
    { name: 'Washington' },
    { name: 'WestVirginia' },
    { name: 'Wisconsin' },
    { name: 'Wyoming' }
  ];
  var substringMatcher = function(states) {
    return function findMatches(q, cb) {
      var matches, substringRegex;

      // an array that will be populated with substring matches
      matches = [];

      // regex used to determine if a string contains the substring `q`
      substrRegex = new RegExp(q, 'i');

      // iterate through the pool of strings and for any string that
      // contains the substring `q`, add it to the `matches` array
      $.each(states, function(i, state) {
        if (substrRegex.test(state.name)) {
          matches.push(state);
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
    name: 'states',
    displayKey: 'name',
    source: substringMatcher(states)
  });
});