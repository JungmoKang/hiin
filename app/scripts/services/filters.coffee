'use strict';

angular.module("filters", []).filter "gender", ->
  (input) ->
    (if input == '1' then "Male" else "Female")
