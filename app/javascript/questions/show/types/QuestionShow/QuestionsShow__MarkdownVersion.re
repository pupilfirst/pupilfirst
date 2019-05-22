type t = {
  value: string,
  latest: bool,
  versionableId: string,
  versionableType: string,
};

let decode = json =>
  Json.Decode.{
    value: json |> field("value", string),
    latest: json |> field("latest", bool),
    versionableId: json |> field("versionableId", string),
    versionableType: json |> field("versionableType", string),
  };

let versionableType = t => t.versionableType;

let versionableId = t => t.versionableId;

let value = t => t.value;

let versionsForResource = (vId, vType, versions) =>
  versions
  |> List.filter(verion =>
       verion.versionableType == vType && verion.versionableId == vId
     );

let latestVersion = (vId, vType, versions) =>
  versionsForResource(vId, vType, versions)
  |> List.filter(verion => verion.latest)
  |> List.hd;

let latestValue = (vId, vType, versions) =>
  latestVersion(vId, vType, versions).value;

let create = (value, latest, versionableId, versionableType) => {
  value,
  latest,
  versionableId,
  versionableType,
};

let add = (newVersion, versions) => {
  let oldVersions =
    versions
    |> List.map(markV =>
         markV.latest
         && markV.versionableId == newVersion.versionableId
         && markV.versionableType == newVersion.versionableType ?
           create(
             markV.value,
             false,
             markV.versionableId,
             markV.versionableType,
           ) :
           markV
       );

  oldVersions |> List.append([newVersion]);
};