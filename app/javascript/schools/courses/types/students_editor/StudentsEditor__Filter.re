type t = {
  searchString: option(string),
  tags: array(string),
  levelId: option(string),
};

let searchString = t => t.searchString;

let tags = t => t.tags;

let levelId = t => t.levelId;

let empty = () => {searchString: None, tags: [||], levelId: None};

let addTag = (tag, t) => {
  ...t,
  tags: t.tags |> Array.append([|tag|]),
  searchString: None,
};

let changeLevelId = (levelId, t) => {...t, levelId, searchString: None};

let changeSearchString = (searchString, t) => {...t, searchString};
