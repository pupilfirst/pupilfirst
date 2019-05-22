type t = {
  id: string,
  value: string,
  latest: bool,
  versionableId: string,
  versionableType: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    value: json |> field("value", string),
    latest: json |> field("latest", bool),
    versionableId: json |> field("versionableId", string),
    versionableType: json |> field("versionableType", string),
  };

let versionableType = t => t.versionableType;

let versionableId = t => t.versionableId;

let value = t => t.value;

let id = t => t.id;

let latestValue = (vId, vType, versions) => {
  let latestVersion =
    versions
    |> List.filter(verion =>
         verion.versionableType == vType
         && verion.versionableId == vId
         && verion.latest
       )
    |> List.hd;
  latestVersion.value;
};