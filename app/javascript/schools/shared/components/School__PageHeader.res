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
    <div className="bg-gray-50">
      <div className="max-w-5xl mx-auto pt-10 px-2">
        <div>
          <Link
            href={exitUrl}
            className="bg-gray-100 px-3 py-1 text-gray-600 rounded-xl text-sm hover:text-primary-500 hover:bg-primary-50 focus:outline-none focus:text-primary-500 focus:bg-primary-50 focus:ring-1 focus:ring-focusColor-500 ">
            <i className="fas fa-arrow-left" /> <span className="ml-2"> {str("Back")} </span>
          </Link>
        </div>
        <h1 className="text-2xl font-bold mt-4"> {str(title)} </h1>
        <p className="text-sm text-gray-600 mb-6"> {str(description)} </p>
        <div className="flex font-semibold text-sm">
          {links
          ->Js.Array2.mapi((link, index) => {
            <Link
              href={link.href}
              className={selectedClasses(link.selected)}
              key={string_of_int(index)}>
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
