let defaultMaxSize = 5 * 1024 * 1024;

let hasValidSize = (~maxSize, file) => file##size <= maxSize;

let isImage = file => {
  Js.log(file##_type);
  switch (file##_type) {
  | "image/jpeg"
  | "image/gif"
  | "image/png" => true
  | _ => false
  };
};

let isValid = (~maxSize=defaultMaxSize, ~image=false, file) => {
  let sizeValid = hasValidSize(~maxSize, file);
  let imageValid = image ? isImage(file) : true;

  sizeValid && imageValid;
};

let isInvalid = (~maxSize=defaultMaxSize, ~image=false, file) =>
  !isValid(~maxSize, ~image, file);
