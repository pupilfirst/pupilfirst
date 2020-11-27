type sortBy =
  | Name
  | CreatedAt
  | UpdatedAt

type sortDirection = [#Ascending | #Descending]

type t = {
  searchString: option<string>,
  tags: array<string>,
  levelId: option<string>,
  sortBy: sortBy,
  sortDirection: sortDirection,
}

let searchString = t => t.searchString

let tags = t => t.tags

let levelId = t => t.levelId

let sortBy = t => t.sortBy

let sortDirection = t => t.sortDirection

let make = () => {
  searchString: None,
  tags: [],
  levelId: None,
  sortBy: Name,
  sortDirection: #Ascending,
}

let addTag = (tag, t) => {...t, tags: t.tags |> Array.append([tag])}

let changeLevelId = (levelId, t) => {...t, levelId: levelId}

let changeSearchString = (searchString, t) => {...t, searchString: searchString}

let removeTag = (tag, t) => {
  ...t,
  tags: t.tags |> Js.Array.filter(ts => ts != tag),
}

let removeLevelId = t => {...t, levelId: None}

let removeSearchString = t => {...t, searchString: None}

let updateSortBy = (sortBy, t) => {...t, sortBy: sortBy}

let sortByToString = t =>
  switch t.sortBy {
  | Name => "name"
  | CreatedAt => "created_at"
  | UpdatedAt => "updated_at"
  }

let dropdownOptionsForSortBy = t =>
  switch t.sortBy {
  | Name => [CreatedAt, UpdatedAt]
  | CreatedAt => [Name, UpdatedAt]
  | UpdatedAt => [Name, CreatedAt]
  }

let sortByTitle = sortBy =>
  switch sortBy {
  | Name => "Name"
  | CreatedAt => "Last Created"
  | UpdatedAt => "Last Updated"
  }

let isEmpty = t =>
  switch (t.searchString, t.levelId, t.tags |> ArrayUtils.isEmpty) {
  | (None, None, true) => true
  | (_, _, _) => false
  }

let clear = t => {...t, searchString: None, levelId: None, tags: []}
