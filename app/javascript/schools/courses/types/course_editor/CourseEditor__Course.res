exception UnexpectedProgressionBehavior(string)

module Image = {
  type t = {
    url: string,
    filename: string,
  }

  let url = t => t.url
  let filename = t => t.filename

  let make = (url, filename) => {url: url, filename: filename}

  let decode = json => {
    open Json.Decode
    {
      url: field("url", string, json),
      filename: field("filename", string, json),
    }
  }
}

module Highlight = {
  type t = {
    title: string,
    icon: string,
    description: string,
  }

  let title = t => t.title
  let icon = t => t.icon
  let description = t => t.description

  let make = (title, description, icon) => {title: title, description: description, icon: icon}

  let updateTitle = (t, title) => {...t, title: title}
  let updateDescription = (t, description) => {...t, description: description}
  let updateIcon = (t, icon) => {...t, icon: icon}

  let decode = json => {
    open Json.Decode
    {
      icon: field("icon", string, json),
      title: field("title", string, json),
      description: field("description", string, json),
    }
  }

  let empty = () => {
    icon: "badge-check-solid",
    title: "",
    description: "",
  }

  let isInvalid = t =>
    t.icon == "" || Js.String.trim(t.description) == "" || Js.String.trim(t.title) == ""

  let isInValidArray = array => Js.Array.some(isInvalid, array)
}

type progressionBehavior =
  | Limited(int)
  | Unlimited
  | Strict

type t = {
  id: string,
  name: string,
  description: string,
  endsAt: option<Js.Date.t>,
  about: option<string>,
  publicSignup: bool,
  publicPreview: bool,
  thumbnail: option<Image.t>,
  cover: option<Image.t>,
  featured: bool,
  progressionBehavior: progressionBehavior,
  archivedAt: option<Js.Date.t>,
  highlights: array<Highlight.t>,
  processingUrl: option<string>,
}

let name = t => t.name

let id = t => t.id

let endsAt = t => t.endsAt

let about = t => t.about

let publicSignup = t => t.publicSignup

let publicPreview = t => t.publicPreview

let description = t => t.description

let featured = t => t.featured

let cover = t => t.cover

let thumbnail = t => t.thumbnail

let archivedAt = t => t.archivedAt

let highlights = t => t.highlights

let processingUrl = t => t.processingUrl

let progressionBehavior = t =>
  switch t.progressionBehavior {
  | Limited(_) => #Limited
  | Unlimited => #Unlimited
  | Strict => #Strict
  }

let progressionLimit = t =>
  switch t.progressionBehavior {
  | Limited(limit) => Some(limit)
  | Unlimited
  | Strict =>
    None
  }

let imageUrl = image => image |> Image.url

let filename = image => image |> Image.filename

let updateList = (course, courses) => {
  Js.Array.map(c => c.id == course.id ? course : c, courses)
}

let makeImageFromJs = data =>
  switch data {
  | Some(image) => Some(Image.make(image["url"], image["filename"]))
  | None => None
  }

let addImages = (~coverUrl, ~thumbnailUrl, ~coverFilename, ~thumbnailFilename, t) => {
  ...t,
  cover: switch coverUrl {
  | Some(coverUrl) => Some(Image.make(coverUrl, coverFilename))
  | None => None
  },
  thumbnail: switch thumbnailUrl {
  | Some(thumbnailUrl) => Some(Image.make(thumbnailUrl, thumbnailFilename))
  | None => None
  },
}

let replaceImages = (cover, thumbnail, t) => {...t, cover: cover, thumbnail: thumbnail}

let makeFromJs = rawCourse => {
  let endsAt = Belt.Option.map(rawCourse["endsAt"], DateFns.decodeISO)
  let archivedAt = Belt.Option.map(rawCourse["archivedAt"], DateFns.decodeISO)

  let progressionBehavior = switch rawCourse["progressionBehavior"] {
  | #Limited => Limited(rawCourse["progressionLimit"] |> Belt.Option.getExn)
  | #Unlimited => Unlimited
  | #Strict => Strict
  }

  {
    id: rawCourse["id"],
    name: rawCourse["name"],
    description: rawCourse["description"],
    endsAt: endsAt,
    about: rawCourse["about"],
    publicSignup: rawCourse["publicSignup"],
    publicPreview: rawCourse["publicPreview"],
    thumbnail: makeImageFromJs(rawCourse["thumbnail"]),
    cover: makeImageFromJs(rawCourse["cover"]),
    featured: rawCourse["featured"],
    progressionBehavior: progressionBehavior,
    archivedAt: archivedAt,
    highlights: Js.Array.map(
      c => Highlight.make(c["title"], c["description"], c["icon"]),
      rawCourse["highlights"],
    ),
    processingUrl: rawCourse["processingUrl"],
  }
}

let decode = json => {
  let behavior = json |> {
    open Json.Decode
    field("progressionBehavior", string)
  }

  let progressionBehavior = switch behavior {
  | "Limited" =>
    let progressionLimit = json |> {
      open Json.Decode
      field("progressionLimit", int)
    }
    Limited(progressionLimit)
  | "Unlimited" => Unlimited
  | "Strict" => Strict
  | otherValue =>
    Rollbar.error("Unexpected progressionBehavior: " ++ otherValue)
    raise(UnexpectedProgressionBehavior(behavior))
  }

  open Json.Decode
  {
    id: field("id", string, json),
    name: field("name", string, json),
    description: field("description", string, json),
    endsAt: optional(field("endsAt", string), json)->Belt.Option.map(DateFns.parseISO),
    progressionBehavior: progressionBehavior,
    about: optional(field("about", string), json),
    publicSignup: field("publicSignup", bool, json),
    publicPreview: field("publicPreview", bool, json),
    thumbnail: optional(field("thumbnail", Image.decode), json),
    cover: optional(field("cover", Image.decode), json),
    featured: field("featured", bool, json),
    archivedAt: optional(field("archivedAt", string), json)->Belt.Option.map(DateFns.parseISO),
    highlights: field("highlights", array(Highlight.decode), json),
    processingUrl: field("processingUrl", optional(string), json),
  }
}

module Fragments = %graphql(`
  fragment CourseFragment on Course {
    id
    name
    description
    endsAt
    about
    publicSignup
    publicPreview
    thumbnail {
      url
      filename
    }
    cover {
      url
      filename
    }
    featured
    progressionBehavior
    progressionLimit
    archivedAt
    highlights{
      icon
      title
      description
    }
    processingUrl
  }
  `)
