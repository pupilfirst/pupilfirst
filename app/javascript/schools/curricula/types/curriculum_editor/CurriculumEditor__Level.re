type persistedDetails = {
  id: int,
  levelNumber: int,
};

type unpersistedDetails = {
  name: string,
  unlockOn: option(string),
};

type persisted = [ | `Persisted(persistedDetails, unpersistedDetails)];

type editable = [ persisted | `Unpersisted(unpersistedDetails)];

let unpersistedDetails = persisted =>
  switch (persisted) {
  | `Persisted(_pd, unpersistedDetails) => unpersistedDetails
  };

let persistedDetails = persisted =>
  switch (persisted) {
  | `Persisted(persistedDetails, _ud) => persistedDetails
  };

let id = persisted =>
  switch (persisted) {
  | `Persisted(persistedDetails, _ud) => persistedDetails.id
  };

let name = editable =>
  switch (editable) {
  | `Persisted(_pd, unpersistedDetails) => unpersistedDetails.name
  | `Unpersisted(unpersistedDetails) => unpersistedDetails.name
  };

let levelNumber = persisted =>
  switch (persisted) {
  | `Persisted(persistedDetails, _ud) => persistedDetails.levelNumber
  };

let unlockOn = editable =>
  switch (editable) {
  | `Persisted(_pd, unpersistedDetails) => unpersistedDetails.unlockOn
  | `Unpersisted(unpersistedDetails) => unpersistedDetails.unlockOn
  };

let decode = json =>
  `Persisted((
    Json.Decode.{
      id: json |> field("id", int),
      levelNumber: json |> field("levelNumber", int),
    },
    Json.Decode.{
      name: json |> field("name", string),
      unlockOn:
        json |> field("unlockOn", nullable(string)) |> Js.Null.toOption,
    },
  ));

let selectLevel = (levels, levelName) =>
  levels
  |> List.find(l =>
       switch (l) {
       | `Persisted(_pd, unpersistedDetails) =>
         unpersistedDetails.name == levelName
       }
     );

let empty = () => `Unpersisted({name: "", unlockOn: None});