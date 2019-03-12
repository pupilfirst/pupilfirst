type t = {
  id: int,
  name: string,
  imageUrl: string,
  email: string,
  title: string,
  linkedinUrl: option(string),
  public: bool,
  connectLink: option(string),
  notifyForSubmission: bool,
};

let name = t => t.name;

let id = t => t.id;

let email = t => t.email;

let imageUrl = t => t.imageUrl;

let title = t => t.title;

let linkedinUrl = t => t.linkedinUrl;

let public = t => t.public;

let connectLink = t => t.connectLink;

let notifyForSubmission = t => t.notifyForSubmission;

let updateInfo = (name, coach) => {...coach, name};

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    imageUrl: json |> field("imageUrl", string),
    email: json |> field("email", string),
    title: json |> field("title", string),
    linkedinUrl:
      json |> field("linkedinUrl", nullable(string)) |> Js.Null.toOption,
    public: json |> field("public", bool),
    connectLink:
      json |> field("connectLink", nullable(string)) |> Js.Null.toOption,
    notifyForSubmission: json |> field("notifyForSubmission", bool),
  };