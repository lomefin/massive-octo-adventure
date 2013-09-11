class GeopositionSimulator

  constructor: (@options = {})->
    @bounds = if @options.bounds? then @options.bounds else {start:{latitude:33.3,longitude:70.5} , radius: 70000}
    @MAX_STEP = if @options.step? then @options.step else 5 #5 meters
    @lastPosition = @bounds.start

  rad: (x)->
    x*Math.PI/180

  deg: (theta)->
    180*theta/Math.PI
  
  haversine: (angleRadians)->
    Math.sin(angleRadians/2.0) * Math.sin(angleRadians/2.0)

  inverseHaversine: (h)->
    return 2 * Math.asin(Math.sqrt(h))

  distanceBetweenPoints:(p1,p2)->
    lat1 = p1.latitude
    lat2 = p2.latitude
    lon1 = p1.longitude
    lon2 = p2.longitude
    RADIUS = 6371.0
    lat1 = @rad(lat1)
    lat2 = @rad(lat2)
    dlat = lat2 - lat1
    dlon = @rad(lon2 - lon1)
    h = @haversine(dlat) + Math.cos(lat1) * Math.cos(lat2) * @haversine(dlon)
    RADIUS * @inverseHaversine(h)

  distHaversine: (p1,p2)->
    R = 6371
    dLat  = @rad(p2.latitude - p1.latitude)
    dLong = @rad(p2.longitude - p1.longitude)

    a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(@rad(p1.latitude)) * Math.cos(@rad(p2.latitude)) * Math.sin(dLong/2) * Math.sin(dLong/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    R * c

  boundingBox:(position, distance)->
    lat = position.latitude
    lon = position.longitude
    RADIUS = 6371.0
    dlat = distance / RADIUS
    dlon = Math.asin(Math.sin(dlat) / Math.cos(@rad(lat)))
    {latitude: @deg(dlat), longitude: @deg(dlon)}


  testHaversine: (p1,p2)->
    @distHaversine({latitude: 40.713955826286046, longitude: -74.00665283203125},{latitude: 39.952335, longitude: -75.163789})

  testDistanceBetweenPoints: ()->
    @distanceBetweenPoints({latitude: 40.713955826286046, longitude: -74.00665283203125},{latitude: 39.952335, longitude: -75.163789})

  runTests:()->
    position1 = {latitude:40.713955826286046,longitude:-74.00665283203125}
    position2 = {latitude: 39.952335, longitude: -75.163789}
    console.log "Position 1: ", position1
    console.log "Position 2: ", position2
    console.log "Haversine"
    h = @distHaversine(position1,position2)
    console.log h
    console.log "DistanceBetweenPoints"
    dbp = @distanceBetweenPoints(position1,position2)
    console.log dbp
    console.log "Difference"
    console.log h-dbp
    d = 0.005
    console.log "BoundingBox Delta of ", d, " km from position 1"
    delta = @boundingBox(position1,d)
    console.log delta
    console.log "Previous position 1: ", position1
    position1b = {latitude: position1.latitude + delta.latitude, longitude: position1.longitude - delta.longitude}
    console.log "New position 1b:", position1b
    h1b = @distanceBetweenPoints(position1,position1b)
    console.log "Distance between p1 and p1b: ", h1b

  randomDeltaOfRadius: (r)->
    result = -r + Math.random()*2*r
    #result = (Math.random()*2)*(r-1)
    console.log "randomPointOfRadius ", -r, result, r
    result

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
