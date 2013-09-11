window.simulated_geoposition or= {}

window.simulated_geoposition.geolocation = class geolocation

  @currentSimulator = null
  @watchIds = []
  @getSimulator: ()->
    if not @currentSimulator?
      @currentSimulator = new GeopositionSimulator()
    @currentSimulator

  @configure:(@options)->

  @getCurrentPosition:(success,error,options) ->
    @currentSimulator.getCurrentPosition(success,error,options)


  @watchPosition:(success,error,options) ->
    id = setInterval((()=> @getCurrentPosition(success,error,options)),options.interval)
    @watchIds.append id
    id

  @clearWatch:(watchId) ->
    clearInterval watchId

