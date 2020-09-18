[@bs.deriving abstract]
type uploadOptions = {
  uploadUrl: string,
  onError: (string) => Js.nullable(string),
  onSuccess: (unit) => Js.nullable(string)
};

type uO;
[@bs.module "tus-js-client"] [@bs.new]
external jsTusUpload: (Js.Json.t, uploadOptions) => uO = "Upload";

[@bs.send.pipe : uO]
external start: unit => uO = "start";

let tusUpload = (file, uploadUrl, onSuccess, onError) => {
  let options = uploadOptions(~uploadUrl, ~onSuccess, ~onError)
  jsTusUpload(file, options)
  |> start();
}
