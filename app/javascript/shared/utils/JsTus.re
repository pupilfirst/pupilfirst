[@bs.deriving abstract]
type uploadOptions = {
  uploadUrl: string,
  onError: (string) => string,
  onSuccess: (string) => string,
};

[@bs.deriving abstract]
type uploadObject = {
  start: int
};

[@bs.module "tus-js-client"]
external jsTusUpload: (Js.Json.t, uploadOptions) => uploadObject = "Upload";


let tusUpload = (file, uploadUrl, onSuccess, onError) => {
  let options = uploadOptions(~uploadUrl, ~onSuccess, ~onError)
  jsTusUpload(file, options);
}
