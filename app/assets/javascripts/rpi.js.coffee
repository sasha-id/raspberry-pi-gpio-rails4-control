$ ->
  window.gpioController = new Gpio.Controller($('#gpio').data('uri'));

window.Gpio = {}
dispatcher = null

class Gpio.Controller
  constructor: (url) ->
    dispatcher = new WebSocketRails(url)
    @channel = dispatcher.subscribe('default')
    @init()
    @bindEvents()
  init: =>
    console.log "Init"
    @watchPins()
  watchPins: =>
    pins = []
    $('[data-watch="true"]').each ->
      data = $(this).data()
      pins.push data
      console.log "Watch pin: "
      $.each data, (key, value) ->
        console.log "\t" + key + ": " + value
    dispatcher.trigger 'watch', pins
  bindEvents: =>
    @channel.bind 'switch', @switch


    $("button[data-pin]").on 'click', (e) ->
      pin = $(this).data()
      pin['value'] = 'click'
      console.log "click:"
      console.log pin
      dispatcher.trigger 'switch', pin

    

    $("[data-pin]").on "switch-change", (e, data) ->
      $element = $(data.el)
      pin = $(this).data()
      value = data.value
      console.log "change:"
      console.log pin
      console.log e, data, $element, value
      pin['value'] = value
      dispatcher.trigger 'switch', pin
  switch: (data) =>
    console.log "switch:"
    console.log data
    $('[data-pin=' + data['pin'] + ']').bootstrapSwitch('setState', data['value'], true)

