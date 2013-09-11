class GeopositionSimulator

  constructor: (@options = {})->
    @bounds = if @options.bounds? then @options.bounds else {start:{latitude:33.3,longitude:70.5} , radius: 70000}
    @MAX_STEP = if @options.step? then @options.step else 5 #5 meters
    @lastPosition = @bounds.start
    @lastPosition.timestamp = new Date()
    @RADIUS = 6371.0

  rad: (x)->
    x*Math.PI/180

  deg: (theta)->
    180*theta/Math.PI

  haversine: (angleRadians)->
    Math.sin(angleRadians/2.0) * Math.sin(angleRadians/2.0)

  inverseHaversine: (h)->
    return 2 * Math.asin(Math.sqrt(h))

  distanceBetweenPoints:(p1,p2)->
    lat1 = @rad(p1.latitude)
    lat2 = @rad(p2.latitude)
    dlat = p2.latitude - p1.latitude
    dlon = @rad(p2.longitude - p1.longitude)
    h = @haversine(dlat) + Math.cos(p1.latitude) * Math.cos(p2.latitude) * @haversine(dlon)
    @RADIUS * @inverseHaversine(h)

  boundingBox:(position, distance)->
    dlat = distance / @RADIUS
    dlon = Math.asin(Math.sin(dlat) / Math.cos(@rad(position.latitude)))
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
                    timestamp: new Date()
    difference = {latitude: newPosition.latitude-@lastPosition.latitude,longitude: newPosition.longitude-@lastPosition.longitude}
    newHeading = @deg(Math.atan(difference.latitude/difference.longitude))
    speed = @distanceBetweenPoints(newPosition, @lastPosition)/(newPosition.timestamp-@lastPosition.timestamp) 
    coords = 
              latitude: newPosition.latitude
              longitude: newPosition.longitude
              altitude: 0
              accuracy: 0
              altitudeAccuracy: 0
              heading: newHeading
              speed: speed
    @lastPosition = newPosition

    position =
              coords: coords
              timestamp: new Date().getTime()

  getCurrentPosition:(success,error,options) =>
    newPosition = @generateNewPosition()
    success(newPosition)

window.GeopositionSimulator = GeopositionSimulator
