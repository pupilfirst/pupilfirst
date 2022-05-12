let str = React.string

type link = {
  title: string,
  href: string,
  icon: string,
  selected: bool,
}

let makeLink = (~title, ~href, ~selected=false, ~icon) => {
  title: title,
  href: href,
  selected: selected,
  icon: icon,
}

let selectedClasses = bool => {
  "px-3 py-3 md:py-2 -mb-px " ++ {
    bool ? "text-primary-500 border-b-3 border-primary-500" : "text-gray-500"
  }
}

@react.component
let make = (~exitUrl, ~title, ~description, ~links=[]) => {
  <>
    <Helmet> <title> {str(title)} </title> </Helmet>
    <div className="bg-gray-200">
      <div className="max-w-5xl mx-auto pt-10">
        <div>
          <Link href={exitUrl} className="bg-gray-300 px-2 py-1 text-gray-800 rounded text-sm">
            <i className="fas fa-arrow-left" /> <span className="ml-1"> {str("Back")} </span>
          </Link>
        </div>
        <h1 className="text-3xl font-bold mt-6"> {str(title)} </h1>
        <h2 className="text-lg font-light"> {str(description)} </h2>
        <div className="flex font-semibold text-sm pt-6">
          {links
          ->Js.Array2.map(link => {
            <Link href={link.href} className={selectedClasses(link.selected)}>
              <div>
                <i className={link.icon} /> <span className="ml-2"> {str(link.title)} </span>
              </div>
            </Link>
          })
          ->React.array}
        </div>
      </div>
    </div>
  </>
}
