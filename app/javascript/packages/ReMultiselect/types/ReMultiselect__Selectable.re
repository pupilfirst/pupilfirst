type t = {
  id: option(string),
  label: option(string),
  item: string,
  color: string,
  searchString: string,
  resourceType: string,
};

let id = t => t.id;

let label = t => t.label;

let item = t => t.item;

let color = t => t.color;

let searchString = t => t.searchString;

let resourceType = t => t.resourceType;

let make =
    (
      ~id=None,
      ~label=None,
      ~item,
      ~color="gray",
      ~searchString=item,
      ~resourceType,
      (),
    ) => {
  id,
  label,
  item,
  color,
  searchString,
  resourceType,
};

let copyAndSort = (f, t) => {
  let cp = t |> Array.copy;
  cp |> Array.sort(f);
  cp;
};

let search = (searchString, selections) =>
  selections
  |> Js.Array.filter(selection =>
       selection.searchString
       |> String.lowercase_ascii
       |> Js.String.includes(searchString |> String.lowercase_ascii)
     )
  |> copyAndSort((x, y) => String.compare(x.item, y.item));
