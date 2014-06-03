(function() {
  'use strict';
  angular.module("filters", []).filter("gender", function() {
    return function(input) {
      if (input === '1') {
        return "Male";
      } else {
        return "Female";
      }
    };
  });

}).call(this);
