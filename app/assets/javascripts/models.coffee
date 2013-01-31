class @Song
  constructor: (@url, @name, @artist) ->

  full_name: () -> "#{@name} by #{@artist}"

