let str = React.string
let ts = I18n.t(~scope="shared")

type link = {
  title: string,
  href: string,
  icon: string,
  selected: bool,
}

let makeLink = (~selected=false, ~title, ~href, ~icon) => {
  title,
  href,
  selected,
  icon,
}

let selectedClasses = bool => {
  "px-1 py-3 md:py-2 -mb-px " ++ {
    bool ? "text-primary-500 border-b-3 border-primary-500" : "text-gray-500"
  }
}

@react.component
let make = (~exitUrl, ~title, ~description, ~links=[]) => {
  <>
    <Helmet>
      <title> {str(title)} </title>
    </Helmet>
    <div className="bg-gray-50 border-b">
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 pt-12">
        <div>
          <Link
            href={exitUrl}
            className="bg-gray-200 px-3 py-1 text-gray-600 rounded-xl text-sm hover:text-primary-500 hover:bg-primary-50 focus:outline-none focus:text-primary-500 focus:bg-primary-50 focus:ring-1 focus:ring-focusColor-500 ">
            <i className="fas fa-arrow-left rtl:rotate-180" />
            <span className="ms-2"> {ts("back_link")->str} </span>
          </Link>
        </div>
        <h1 className="text-2xl font-bold mt-4"> {str(title)} </h1>
        <p className="text-sm text-gray-600 mb-6"> {str(description)} </p>
        <div className="flex font-semibold text-sm gap-6">
          {links
          ->Js.Array2.mapi((link, index) => {
            link.selected
              ? <div
                  key={string_of_int(index)}
                  href={link.href}
                  className={selectedClasses(link.selected)}>
                  {Js.String2.startsWith(link.icon, "if")
                    ? <PfIcon className={link.icon} />
                    : <i className={link.icon} />}
                  <span className="ms-2"> {str(link.title)} </span>
                </div>
              : <Link
                  href={link.href}
                  className={selectedClasses(link.selected)}
                  key={string_of_int(index)}>
                  <div>
                    {Js.String2.startsWith(link.icon, "if")
                      ? <PfIcon className={link.icon} />
                      : <i className={link.icon} />}
                    <span className="ms-2"> {str(link.title)} </span>
                  </div>
                </Link>
          })
          ->React.array}
        </div>
      </div>
    </div>
  </>
}
