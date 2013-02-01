@PlayerController = ($scope, $rootScope) ->
  $scope.audio = null

  $rootScope.$on 'play-track', (event, track) ->
    $scope.$apply () ->
      $scope.audio = new Audio(track)
      $scope.audio.load($scope)

  $scope.$on 'loaded', () ->
    $scope.$apply () ->
      $scope.audio.playing = true

  $scope.resume = () ->
    if $scope.audio
        $scope.audio.resume()

  $scope.pause = () ->
    if $scope.audio
        $scope.audio.pause()

  render_progress = () ->
    requestAnimFrame(render_progress)

    if $scope.audio is null or not $scope.audio.playing
      return

    duration = $scope.audio.source.buffer.duration
    current = $scope.audio.context.currentTime

    canvas = document.getElementById('progressbar')
    context = canvas.getContext('2d')

    width = canvas.width * current / duration

    context.fillRect(0, 0, width, canvas.height)

  render_fft = () ->
    requestAnimFrame(render_fft)

    if $scope.audio is null or not $scope.audio.playing
      return

    num_bars = 60

    canvas = document.getElementById('fft')
    context = canvas.getContext('2d')
    analyzer = $scope.audio.analyzer

    data = new Uint8Array(analyzer.fftSize)
    analyzer.getByteFrequencyData(data)

    context.clearRect(0, 0, canvas.width, canvas.height)

    bar_width = canvas.width / num_bars
    bin_size = Math.floor(data.length / num_bars / 2.2)
    for i in [0...num_bars]
      sum = 0
      for j in [0...bin_size]
        sum += data[j + i * bin_size]

      average = sum / bin_size
      scaled = average / 256 * canvas.height
      context.fillRect(i * bar_width, canvas.height, bar_width - 2, -scaled)

  render_fft()
  render_progress()

  # just for testing
  $(document).ready () ->
    $rootScope.$broadcast('play-track', new Track({
      url: "http://localhost:8080/DAFT%20PUNK/ALIVE%20SUMMER%202006/05%20Around%20The%20World%20_%20Harder%20Better%20Faster%20Stronger.mp3",
      name: "Around the world",
      artist: "Daft Punk"
    }))

@LibraryController = ($scope, $rootScope, $http) ->
  $scope.songs = []

  $http.get('/songs.json').success (data) ->
    $scope.songs = data
    for song, index in $scope.songs
      song.index = index
