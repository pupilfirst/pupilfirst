@val @scope(("window", "pupilfirst"))
external maxUploadFileSize: int = "maxUploadFileSize"

let defaultVideoMaxSize = 500 * 1024 * 1024

let hasValidSize = (~maxSize, file) => file["size"] <= maxSize

let hasValidFloatSize = (~maxSize: float, file) => file["size"] <= maxSize

let isImage = file =>
  switch file["_type"] {
  | "image/jpeg"
  | "image/gif"
  | "image/png" => true
  | _ => false
  }

let isVideo = file =>
  switch file["_type"] {
  | "video/mp4"
  | "video/quicktime"
  | "video/x-ms-asf"
  | "video/x-ms-wmv"
  | "video/vnd.avi"
  | "video/avi"
  | "video/msvideo"
  | "video/x-msvideo" => true
  | _ => false
  }

let isAudio = file =>
  switch file["_type"] {
  | "audio/wav"
  | "audio/mpeg"
  | "audio/ogg" => true
  | _ => false
  }

let isValid = (~maxSize=maxUploadFileSize, ~image=false, ~video=false, file) => {
  let maxSize = video ? defaultVideoMaxSize : maxSize
  let sizeValid = hasValidSize(~maxSize, file)

  let imageValid = image ? isImage(file) : true
  let videoValid = video ? isVideo(file) : true

  sizeValid && (imageValid && videoValid)
}

let isInvalid = (~maxSize=maxUploadFileSize, ~image=false, ~video=false, file) =>
  !isValid(~maxSize, ~image, ~video, file)
