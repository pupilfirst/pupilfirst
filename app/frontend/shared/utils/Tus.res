type file

external makeFile: Js.t<'a> => file = "%identity"

@deriving(abstract)
type uploadOptions = {
  uploadUrl: string,
  headers: {"Accept": string},
  onError: string => unit,
  onSuccess: unit => unit,
  onProgress: (int, int) => unit,
}

type uploader
@module("tus-js-client") @new
external jsUpload: (file, uploadOptions) => uploader = "Upload"

@send external start: uploader => unit = "start"

let upload = (~file, ~uploadUrl, ~onSuccess, ~onError, ~onProgress) => {
  let headers = {"Accept": "application/vnd.vimeo.*+json;version=3.4"}
  let options = uploadOptions(~uploadUrl, ~headers, ~onSuccess, ~onError, ~onProgress)
  jsUpload(file, options)->start
}
