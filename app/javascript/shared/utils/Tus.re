type file;

external makeFile: Js.t('a) => file = "%identity";

[@bs.deriving abstract]
type uploadOptions = {
  uploadUrl: string,
  headers: {. "Accept": string },
  onError: string => unit,
  onSuccess: unit => unit,
};

type uploader;
[@bs.module "tus-js-client"] [@bs.new]
external jsUpload: (file, uploadOptions) => uploader = "Upload";

[@bs.send] external start: uploader => unit = "start";

let upload = (~file, ~uploadUrl, ~onSuccess, ~onError) => {
  let headers = { 
    "Accept": "application/vnd.vimeo.*+json;version=3.4"
  }
  let options = uploadOptions(~uploadUrl, ~headers,  ~onSuccess, ~onError);
  jsUpload(file, options)->start;
};
