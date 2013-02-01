# Chrome Bug fixing (mis-synchronization). Based on:
# http://stackoverflow.com/questions/10365335/decodeaudiodata-returning-a-null-error

# Simple wrapper for synchronization
class Node
  constructor: (@buffer) ->
    @sync = 0

class @Audio
  constructor: (@track) ->
    @url = @track.url
    @context = new webkitAudioContext()
    @source = @context.createBufferSource()
    @analyzer = @context.createAnalyser()
    @analyzer.fftSize = 2048
    @loaded = false
    @playing = false
    @currentTime = 0.0

    # Append the analyzer to the source
    @source.connect(@analyzer)
    @analyzer.connect(@context.destination)

  pause: () ->
    @playing = false
    @currentTime = @context.currentTime
    @source.disconnect()

  stop: () ->
    this.pause()
    @currentTime = 0.0

  resume: () ->
    @playing = true
    @source.connect(@analyzer)
    @source.noteOn(@currentTime)

  load: ($scope) ->
    audio = this
    request = new XMLHttpRequest()
    request.open("GET", @url, true)
    request.responseType = "arraybuffer"

    request.onload = () ->
      @audioBuffer = audio.audio_decode(request.response, $scope)
    request.onerror = () ->
      console.log("XHR error")
    request.send()

  audio_decode: (data, $scope) ->
    audio = this
    @context.decodeAudioData(data,
      (buffer) ->
        audio.source.buffer = buffer
        audio.source.loop = false
        audio.source.noteOn(0.0)
        audio.playing = true
        audio.loaded = true
        audio.source.gain.loop = false
        $scope.$broadcast('loaded')
      (error) ->
        console.log("fuu")
        console.log(error)
        node = new Node(data)
        if audio.sync_stream(node)
          console.log("stream synchronized")
          audio.audio_decode(node.buffer, $scope)
        else
          console.log("Unable to sync stream"))

  # Seek the first usable frame
  sync_stream: (node) ->
    buf8 = new Uint8Array(node.buffer)
    buf8.indexOf = Array.prototype.indexOf
    i = node.sync
    b = buf8
    while (1)
      node.retry++
      i = b.indexOf(0xFF,i)
      if i == -1 || (b[i + 1] & 0xE0 == 0xE0)
        break
      i++
    if i != -1
        tmp = node.buffer.slice(i)
        delete(node.buffer)
        node.buffer = null
        node.buffer = tmp
        node.sync = i
        return true
    return false
