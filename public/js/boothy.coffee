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
    img.src = data_uri

  sayCheese.start()
