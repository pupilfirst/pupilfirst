type sortBy =
  | Name
  | CreatedAt
  | UpdatedAt;

type t = {
  searchString: option(string),
  tags: array(string),
  levelId: option(string),
  sortBy,
};

let searchString = t => t.searchString;

let tags = t => t.tags;

let levelId = t => t.levelId;

let sortBy = t => t.sortBy;

let empty = () => {
  searchString: None,
  tags: [||],
  levelId: None,
  sortBy: Name,
};

let addTag = (tag, t) => {...t, tags: t.tags |> Array.append([|tag|])};

let changeLevelId = (levelId, t) => {...t, levelId};

let changeSearchString = (searchString, t) => {...t, searchString};

let removeTag = (tag, t) => {
  ...t,
  tags: t.tags |> Js.Array.filter(ts => ts != tag),
};

let removeLevelId = t => {...t, levelId: None};

let removeSearchString = t => {...t, searchString: None};

let updateSortBy = (sortBy, t) => {...t, sortBy};

let sortByStrings = t => {
  switch (t.sortBy) {
  | Name => "name"
  | CreatedAt => "created_at"
  | UpdatedAt => "updated_at"
  };
};

let sortByListForDropdown = t =>
  switch (t.sortBy) {
  | Name => [|CreatedAt, UpdatedAt|]
  | CreatedAt => [|Name, UpdatedAt|]
  | UpdatedAt => [|Name, CreatedAt|]
  };

let sortByTitle = sortBy => {
  switch (sortBy) {
  | Name => "Name"
  | CreatedAt => "Last Created"
  | UpdatedAt => "Last Updated"
  };
};

let sortByIcon = sortBy => {
  switch (sortBy) {
  | Name => "if i-sort-alpha-down-solid text-sm text-gray-800"
  | CreatedAt => "fas fa-user text-sm text-gray-800"
  | UpdatedAt => "fas fa-user text-sm text-gray-800"
  };
};

let isEmpty = t =>
  switch (t.searchString, t.levelId, t.tags |> ArrayUtils.isEmpty) {
  | (None, None, true) => true
  | (_, _, _) => false
  };

let clear = t => {...t, searchString: None, levelId: None, tags: [||]};
