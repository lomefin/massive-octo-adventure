class GeopositionSimulator

  constructor: (@options = {})->
    @bounds = if @options.bounds? then @options.bounds else {start:{lat:33.3,lng:70.5} , radius: 70000}
    @step = if @options.step? then @options.step else 5 #5 meters
    @lastPosition = @bounds.start
    console.log @lastPosition

  generateNewPosition: ()->
    coords = 
              latitude: 33.3
              longitude: 70.5
              altitude: 0
              accuracy: 0
              altitudeAccuracy: 0
              heading: 0
              speed: 0

    position =
              coords: coords
              timestamp: new Date().getTime()

  getCurrentPosition:(success,error,options) =>
    newPosition = @generateNewPosition()
    success(newPosition)

window.GeopositionSimulator = GeopositionSimulator
