window.simulated_geoposition or= {}

window.simulated_geoposition.geolocation = class geolocation

  @currentSimulator = null

  @getSimulator: ()->
    if not @currentSimulator?
      @currentSimulator = new GeopositionSimulator()
    @currentSimulator

  @configure:(@options)->

  @getCurrentPosition:(success,error,options) ->
    @currentSimulator.getCurrentPosition(success,error,options)


  @watchPosition:(success,error,options) ->
    @getCurrentPosition(success,error,options)

  @clearWatch:(watchId) ->
    #do nothing

