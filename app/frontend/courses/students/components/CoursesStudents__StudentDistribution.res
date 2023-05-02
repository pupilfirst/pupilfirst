%%raw(`import "./CoursesStudents__StudentDistribution.css"`)

open CoursesStudents__Types
let str = React.string
let tr = I18n.t(~scope="components.CoursesStudents__StudentDistribution")
let ts = I18n.t(~scope="shared")

let stylingForLevelPills = percentageStudents => {
  let emptyStyle = ReactDOM.Style.make()
  let styleWithWidth = ReactDOM.Style.make(~width=percentageStudents->Js.Float.toString ++ "%", ())

  if 0.0 == percentageStudents {
    ("w-8 flex-grow", emptyStyle, "bg-green-200 text-green-800")
  } else if 0.0 <= percentageStudents && percentageStudents < 5.0 {
    ("w-8 flex-shrink-0", emptyStyle, "bg-green-200 text-green-800")
  } else if 5.0 <= percentageStudents && percentageStudents < 20.0 {
    ("", styleWithWidth, "bg-green-300 text-green-800")
  } else if 20.0 <= percentageStudents && percentageStudents < 40.0 {
    ("", styleWithWidth, "bg-green-400 text-green-900")
  } else if 40.0 <= percentageStudents && percentageStudents < 60.0 {
    ("", styleWithWidth, "bg-green-500 text-white")
  } else if 60.0 <= percentageStudents && percentageStudents < 80.0 {
    ("", styleWithWidth, "bg-green-600 text-white")
  } else {
    ("", styleWithWidth, "bg-green-700 text-white")
  }
}

let onLevelSelect = (value, params, href) => {
  switch params {
  | Some(p) =>
    Webapi.Url.URLSearchParams.set("level", value, p)
    RescriptReactRouter.push("?" ++ Webapi.Url.URLSearchParams.toString(p))
  | None =>
    let search = Webapi.Dom.location->Webapi.Dom.Location.search
    let params = Webapi.Url.URLSearchParams.make(search)
    Webapi.Url.URLSearchParams.set("level", value, params)
    let currentPath = Webapi.Dom.location->Webapi.Dom.Location.pathname
    let searchString = Webapi.Url.URLSearchParams.toString(params)
    let path = Belt.Option.getWithDefault(href, currentPath)
    Webapi.Dom.window->Webapi.Dom.Window.setLocation(`${path}?${searchString}`)
  }
}

let studentDistributionSkeleton =
  <div className="skeleton-body-container w-full mx-auto">
    <div className="skeleton-body-wrapper px-3 lg:px-0">
      <div className="flex">
        <div className="w-1/6">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
        <div className="w-5/12">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
        <div className="w-1/4">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
        <div className="w-1/12">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
        <div className="w-1/12">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
      </div>
    </div>
  </div>

@react.component
let make = (~studentDistribution, ~params=?, ~href=?) => {
  <div ariaLabel="Students level-wise distribution" className="w-full py-4">
    {"New distribution loading"->str}
  </div>
}

let makeFromJson = props => {
  open Json.Decode

  let studentDistribution = field("studentDistribution", array(DistributionInLevel.decode), props)
  let href = optional(field("href", string), props)

  make({
    "studentDistribution": studentDistribution,
    "params": None,
    "href": href,
  })
}
