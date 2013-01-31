@LibraryController = ($scope, $rootScope, $http) ->
  $scope.addToPlaylist = (index) ->
    song = $scope.songs[index]
    $rootScope.$broadcast('add-song-playlist', new Song(song.url, song.name, song.artist))

  $http.get('/songs.json').success (data) ->
    $scope.songs = data
    for song, index in $scope.songs
      song.index = index

@PlayerController = ($scope) ->

@PlaylistController = ($scope, $rootScope) ->
  start_song = () -> 
    $rootScope.$broadcast('start-song', $scope.playlist[$scope.current])

  $scope.visible = false
  $scope.playlist = []
  $scope.current = 0

  $scope.startPlaylist = () -> start_song()

  $rootScope.$on 'show-playlist', () ->
    $scope.visible = true

  $rootScope.$on 'add-song-playlist', (event, song) ->
    $scope.playlist.push(song)
    console.log("Song #{song.name} added to playlist")

  $rootScope.$on 'song-ended', () ->
    ++$scope.current
    if ($scope.current is $scope.playlist.length)
      $scope.current = 0
      return
    else
      start_song()

@EqualizerController = ($scope, $rootScope) ->
  $scope.visible = false

  $rootScope.$on 'show-equalizer', () ->
    $scope.visible = true

@PlaybackController = ($scope, $rootScope) ->
  $scope.showPlaylist = () ->
    $rootScope.$broadcast('show-playlist')

  $scope.showEqualizer = () ->
    $rootScope.$broadcast('show-equalizer')

  $rootScope.$on 'start-song', (event, song) ->
    console.log(song)
    $scope.song = song
    #$scope.$digest()
    console.log("let's play #{song.name} by #{song.artist}")
    $scope.audio = new Audio(song.url)
    $scope.audio.load()

  $('audio').on('ended', () -> $rootScope.$broadcast('song-ended'))


# Explicit dependency injections for minification
LibraryController.$inject = ['$scope', '$rootScope', '$http']
PlayerController.$inject = ['$scope']
PlaylistController.$inject = ['$scope', '$rootScope']
EqualizerController.$inject = ['$scope', '$rootScope']
PlaybackController.$inject = ['$scope', '$rootScope']
