type t = {
  id: string,
  name: string,
  imageUrl: string,
  email: string,
  title: string,
  public: bool,
  exited: bool,
  connectLink: option<string>,
  imageFileName: option<string>,
  affiliation: option<string>,
}

let name = t => t.name

let id = t => t.id

let email = t => t.email

let imageUrl = t => t.imageUrl

let title = t => t.title

let public = t => t.public

let connectLink = t => t.connectLink

let exited = t => t.exited

let imageFileName = t => t.imageFileName

let affiliation = t => t.affiliation

let decode = json => {
  open Json.Decode
  {
    name: json |> field("name", string),
    id: json |> field("id", string),
    imageUrl: json |> field("imageUrl", string),
    email: json |> field("email", string),
    title: json |> field("title", string),
    public: json |> field("public", bool),
    connectLink: json |> field("connectLink", nullable(string)) |> Js.Null.toOption,
    exited: json |> field("exited", bool),
    imageFileName: json |> field("imageFileName", nullable(string)) |> Js.Null.toOption,
    affiliation: json |> field("affiliation", nullable(string)) |> Js.Null.toOption,
  }
}

let make = (
  ~id,
  ~name,
  ~imageUrl,
  ~email,
  ~title,
  ~public,
  ~connectLink,
  ~exited,
  ~imageFileName,
  ~affiliation,
) => {
  id: id,
  name: name,
  imageUrl: imageUrl,
  email: email,
  title: title,
  public: public,
  connectLink: connectLink,
  exited: exited,
  imageFileName: imageFileName,
  affiliation: affiliation,
}
