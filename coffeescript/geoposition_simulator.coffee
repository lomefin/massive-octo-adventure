class GeopositionSimulator

  constructor: (@options = {})->
    @bounds = if @options.bounds? then @options.bounds else {start:{latitude:33.3,longitude:70.5} , radius: 70000}
    @MAX_STEP = if @options.step? then @options.step else 5 #5 meters
    @lastPosition = @bounds.start

  rad: (x)->
    x*Math.PI/180

  deg: (theta)->
    180*theta/Math.PI

  boundingBox:(position, distance)->
    lat = position.latitude
    lon = position.longitude
    RADIUS = 6371.0
    dlat = distance / RADIUS
    dlon = Math.asin(Math.sin(dlat) / Math.cos(@rad(lat)))
    {latitude: @deg(dlat), longitude: @deg(dlon)}

  randomDeltaOfRadius: (r)->
    r * (Math.random()*2-1)

  generateNewPosition: ()=>
    
    distance = @MAX_STEP/1000 #We work in meters.
    delta = @boundingBox(@lastPosition,distance)
    rDeltaLat = @randomDeltaOfRadius(delta.latitude)
    rDeltaLng = @randomDeltaOfRadius(delta.longitude)
    newPosition = 
                    latitude: @lastPosition.latitude + rDeltaLat
                    longitude: @lastPosition.longitude + rDeltaLng
    difference = {latitude: newPosition.latitude-@lastPosition.latitude,longitude: newPosition.longitude-@lastPosition.longitude}
    newHeading = @deg(Math.atan(difference.latitude/difference.longitude))
    coords = 
              latitude: newPosition.latitude
              longitude: newPosition.longitude
              altitude: 0
              accuracy: 0
              altitudeAccuracy: 0
              heading: newHeading
              speed: 0
    @lastPosition = newPosition

    position =
              coords: coords
              timestamp: new Date().getTime()

  getCurrentPosition:(success,error,options) =>
    newPosition = @generateNewPosition()
    success(newPosition)

window.GeopositionSimulator = GeopositionSimulator
