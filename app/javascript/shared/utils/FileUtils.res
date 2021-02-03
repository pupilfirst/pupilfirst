let defaultMaxSize = 5 * 1024 * 1024
let defaultVideoMaxSize = 500 * 1024 * 1024

let hasValidSize = (~maxSize, file) => file["size"] <= maxSize

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
  | "video/mov"
  | "video/wmv"
  | "video/avi" => true
  | _ => false
  }

let isCSV = file =>
  switch file["_type"] {
  | "text/csv" => true
  | _ => false
  }

let isValid = (~maxSize=defaultMaxSize, ~image=false, ~video=false, ~csv=false, file) => {
  let maxSize = video ? defaultVideoMaxSize : maxSize
  let sizeValid = hasValidSize(~maxSize, file)

  let imageValid = image ? isImage(file) : true
  let videoValid = video ? isVideo(file) : true
  let csvValid = csv ? isCSV(file) : true

  sizeValid && (imageValid && videoValid && csvValid)
}

let isInvalid = (~maxSize=defaultMaxSize, ~image=false, ~video=false, ~csv=false, file) =>
  !isValid(~maxSize, ~image, ~video, ~csv, file)
