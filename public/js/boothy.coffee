Nimbus.Auth.setup("Dropbox", "q5yx30gr8mcvq4f", "qy64qphr70lwui5", "boothy")

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
  
  # write the ArrayBuffer to a blob, and you're done
  bb = new Blob([ab], {type: mimeString})
  bb

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

$ ->
  sayCheese = new SayCheese("#say-cheese-container")
  sayCheese.on "start", ->
    $("#action-buttons").fadeIn "fast"
    $("#take-snapshot").on "click", (evt) ->
      sayCheese.takeSnapshot()

  sayCheese.on "error", (error) ->
    $alert = $("<div>")
    $alert.addClass("alert alert-error").css "margin-top", "20px"
    if error is "NOT_SUPPORTED"
      $alert.html "<strong>:(</strong> your browser doesn't support this yet!"
    else
      $alert.html "<strong>:(</strong> you have to click 'allow' to try me out!"
    $(".say-cheese").prepend $alert

  sayCheese.on "snapshot", (snapshot) ->
    img = document.createElement("img")
    $(img).on "load", ->
      $("#say-cheese-snapshots").prepend img
    console.log(snapshot)
    data_uri = snapshot.toDataURL("image/png")
    window.blob_test = window.dataURItoBlob(data_uri)
    console.log(window.blob_test)
    
    ###
    callback = (bin) ->
      callback2 = (url) ->
        bin.directlink = url.url
        bin.save()

      Nimbus.Client.Dropbox.Binary.direct_link(bin, callback2)

    Nimbus.Client.Dropbox.Binary.upload_blob(window.blob_test, "webcam" + Math.round(new Date() / 1000).toString() + ".png", callback)
    ###

    console.log("saving pic to Dropbox")
    
    Caman data_uri, "#currentpic", ->  
      @resize( width: 460, height: 345 )
      window.current = @
      @render()
      $(@.canvas).attr("id", "currentpic")
      
    $("#currentpic").attr("src", data_uri)
    window.pic = data_uri

  sayCheese.start()

  for x in binary.all()
    
    callback_two = (url) ->
      x.directlink = url.url
      x.save()

      img = document.createElement("img")
      img.src = url.url
      $("#say-cheese-snapshots").prepend img

    if x.path?
      Nimbus.Client.Dropbox.Binary.direct_link(x, callback_two)


Nimbus.Auth.authorized_callback = ()->
  if Nimbus.Auth.authorized()
    $("#loading").fadeOut()

if Nimbus.Auth.authorized()
  $("#loading").fadeOut()
