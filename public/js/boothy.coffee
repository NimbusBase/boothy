#Nimbus.Auth.setup("Dropbox", "q5yx30gr8mcvq4f", "qy64qphr70lwui5", "boothy")

window.debug = true

sync_object = 
  "GDrive": 
    "key": "424243246254-n6b2v8j4j09723ktif41ln247n75pnts.apps.googleusercontent.com",
    #uncomment following to test with localhost
    #"key": "424243246254-n6b2v8j4j09723ktif41ln247n75pnts.apps.googleusercontent.com",
    "scope": "https://www.googleapis.com/auth/drive",
    "app_name": "boothy"  
  "Dropbox": 
    "key": "q5yx30gr8mcvq4f",
    "secret": "qy64qphr70lwui5",
    "app_name": "boothy"
Nimbus.Auth.setup(sync_object);  

window.dataURItoBlob = (dataURI, callback) ->
  
  # convert base64 to raw binary data held in a string
  # doesn't handle URLEncoded DataURIs - see SO answer #6850276 for code that does this
  byteString = atob(dataURI.split(",")[1])
  
  # separate out the mime component
  mimeString = dataURI.split(",")[0].split(":")[1].split(";")[0]
  
  # write the bytes of the string to an ArrayBuffer
  ab = new ArrayBuffer(byteString.length)
  ia = new Uint8Array(ab)
  i = 0

  while i < byteString.length
    ia[i] = byteString.charCodeAt(i)
    i++
  
  # use the ArrayBuffer as storage for the DataView
  dv = new DataView(ab)
  # write the Dataview to a Blob, and you're done
  bb = new Blob([dv], {type: mimeString})
  bb

window.save_image = () ->
  console.log("save image")
  
  #upload current pic
  data = window.current.canvas.toDataURL()
  blob = window.dataURItoBlob(data)
  console.log("saving pic to Dropbox")
  
  callback = (bin) ->
    callback2 = (url) ->
      bin.directlink = url.url
      bin.save()

    #Nimbus.Client.Dropbox.Binary.direct_link(bin, callback2)

  Nimbus.Binary.upload_blob(blob, "webcam" + Math.round(new Date() / 1000).toString() + ".png", callback)  
  
  #prepend the snapshot
  img = document.createElement("img")
  $(img).on "load", ->
    $("#say-cheese-snapshots").prepend img
  img.src = data
  

#log out and delete everything in localstorage
window.log_out = ->
  for key, val of localStorage
    console.log(key)
    delete localStorage[key]
  $("#loading").show()


window.delete_all_binary = () ->
  for x in binary.all()
    if x.path?
      Nimbus.Client.Dropbox.Binary.delete_file(x)
    x.destroy()

window.filter = (name) ->

  Caman window.pic, "#currentpic", ->  
    @resize( width: 460, height: 345 )
    window.current = @
    @[name]()
    @render()
    $(@.canvas).attr("id", "currentpic")

window.initialize = () ->
  for x in binary.all()
       
    if x.directlink? 
      if Nimbus.Auth.service is "Dropbox" and new Date(x.expiration) > new Date()
        img = document.createElement("img")
        img.src = x.directlink
        $("#say-cheese-snapshots").prepend img
      else if Nimbus.Auth.service is "GDrive"
        img = document.createElement("img")
        img.src = x.directlink
        $("#say-cheese-snapshots").prepend img
    else
    
      callback_two = (url) ->
        x.directlink = url.url
        x.save()

        img = document.createElement("img")
        window.url = url
        img.src = url.url
        $("#say-cheese-snapshots").prepend img

      if x.path?
        Nimbus.Client.Dropbox.Binary.direct_link(x, callback_two)  

$ ->
  sayCheese = new SayCheese("#say-cheese-container")
  sayCheese.on "start", ->
    $("#action-buttons").fadeIn "fast"
    $("#take-snapshot").on "click", (evt) ->
      sayCheese.takeSnapshot()

  sayCheese.on "error", (error) ->
    if error is "NOT_SUPPORTED"
      ios.notify
        title: "Not support"
        message: "Your browser doesn't support this yet! Try Chrome"
      
    else
      ios.notify
        title: "Not authorized"
        message: "You have to click 'allow' to try me out!"    
    
  #what happens when you click snap
  sayCheese.on "snapshot", (snapshot) ->

    console.log(snapshot)
    data_uri = snapshot.toDataURL("image/png")
    window.blob_test = window.dataURItoBlob(data_uri)
    #console.log(window.blob_test)
    
    Caman data_uri, "#currentpic", ->  
      @resize( width: 460, height: 345 )
      window.current = @
      @render()
      $(@.canvas).attr("id", "currentpic")
    
      context = @canvas.getContext('2d')
      
      ###
      date = new Date()
      date_string = "#{ date.getMonth() }/#{ date.getDate() }/#{ date.getFullYear() } "
      context.font = "12px arial"
      context.fillStyle = "rgb(200, 200, 200)"
      context.fillText(date_string, 20, 30)
      ###

    window.pic = data_uri

  window.initialize()

  sayCheese.start()

Nimbus.Auth.authorized_callback = ()->
  if Nimbus.Auth.authorized()
    $("#loading").fadeOut()

    binary.sync_all( ()-> window.initialize() )
    

if Nimbus.Auth.authorized()
  $("#loading").fadeOut()
