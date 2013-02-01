# Simple polyfill by Paul Irish
# http://paulirish.com/2011/requestanimationframe-for-smart-animating/

window.requestAnimFrame = (() ->
    window.requestAnimationFrame       ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame    ||
    window.oRequestAnimationFrame      ||
    window.msRequestAnimationFrame     ||
    (callback) ->
      window.setTimeout(callback, 1000 / 60)
)()

resize_canvas = (name) ->
  canvas = document.getElementById(name)
  jq_canvas = $("canvas##{name}")
  canvas.height = jq_canvas.height()
  canvas.width = jq_canvas.width()

$(document).ready () ->
  $("canvas#fft").resize () -> resize_canvas('fft')
  $("canvas#progress").resize () -> resize_canvas('progressbar')
  resize_canvas('fft')
  resize_canvas('progressbar')
