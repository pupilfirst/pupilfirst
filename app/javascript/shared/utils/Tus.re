type file;

external makeFile: Js.t('a) => file = "%identity";

[@bs.deriving abstract]
type uploadOptions = {
  endpoint: string,
  onError: string => unit,
  onSuccess: unit => unit,
};

type uploader;
[@bs.module "tus-js-client"] [@bs.new]
external jsUpload: (file, uploadOptions) => uploader = "Upload";

[@bs.send] external start: uploader => unit = "start";

let upload = (~file, ~endpoint, ~onSuccess, ~onError) => {
  let options = uploadOptions(~endpoint, ~onSuccess, ~onError);
  jsUpload(file, options)->start;
};
