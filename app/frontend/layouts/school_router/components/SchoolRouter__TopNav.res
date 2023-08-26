open SchoolRouter__Types

let str = React.string

let renderUserLink = (icon, href) => {
  <div key=href className="whitespace-nowrap">
    <a
      ariaLabel="Sign Out"
      title="Sign Out"
      rel="nofollow"
      className="flex justify-center items-center text-xs text-gray-500 bg-gray-50 px-2 py-2 rounded cursor-pointer font-semibold hover:text-red-800 focus:ring ring-gray-300 ring-offset-2 hover:bg-red-100 focus:bg-red-200 transition"
      href>
      <FaIcon classes={"fas fw fa-" ++ icon} />
    </a>
  </div>
}

let showUserLink = () => {
  [renderUserLink("power-off", "/users/sign_out")]
}
let navLinks = (path, text) => {
  <div className="me-4">
    <a
      title={text}
      href=path
      className="py-2 px-2 flex text-gray-800 rounded text-sm font-medium hover:text-primary-500 hover:bg-gray-50 items-center focus:outline-none focus:ring-2 focus:ring-focusColor-500">
      {<span> {text->str} </span>}
    </a>
  </div>
}

let showUser = user => {
  <div>
    <div className="flex w-full items-center  rounded-md">
      <div className="flex items-center justify-center rounded-full text-center flex-shrink-0">
        {User.avatarUrl(user)->Belt.Option.mapWithDefault(
          <Avatar
            name={User.name(user)}
            className="w-8 h-8 border border-gray-300 object-contain object-center rounded-full"
          />,
          src =>
            <img
              className="w-9 h-9 border border-gray-300 object-cover object-center rounded-full"
              src
              alt={User.name(user)}
            />,
        )}
      </div>
      <div className="ps-2 flex justify-between w-full items-center">
        // <p className="text-sm font-medium"> {str(User.name(user))} </p>
        <div> {showUserLink()->React.array} </div>
      </div>
    </div>
  </div>
}

let renderPrimaryPageLink = (courseId, primaryPage, secondaryPage) => {
  <div className="flex items-center space-x-2">
    <Link
      className="underline hover:text-primary-500 transition"
      href={`/school/courses/${courseId}/${primaryPage}`}>
      {primaryPage->str}
    </Link>
    <Icon className="if i-chevron-right-light text-gray-400" />
    <p className="text-gray-500"> {secondaryPage->str} </p>
  </div>
}

@react.component
let make = (~courses, ~currentUser) => {
  <div className={"flex justify-between items-center p-4 bg-white border-b flex-1"}>
    <div className="flex items-center space-x-2 text-sm font-semibold">
      <SchoolRouter__CoursesDropdown courses />
    </div>
    <div className="flex items-center ltr:space-x-4">
      <div
        className="py-1 px-2 flex text-sm font-medium border-b-2 border-primary-400 text-primary-500 bg-gray-50 items-center">
        {I18n.t("shared.admin")->str}
      </div>
      {navLinks("/dashboard", I18n.t("shared.dashboard"))}
      <div className="relative me-4">
        <Notifications__Root
          wrapperClasses=""
          iconClasses="school-admin-navbar__notifications-unread-bullet"
          buttonClasses="w-full flex gap-2 relative text-gray-800 text-sm py-2 px-2 rounded hover:text-primary-500 hover:bg-gray-50 font-medium items-center focus:outline-none focus:ring-2 focus:ring-focusColor-500"
          hasNotifications={User.hasNotifications(currentUser)}
        />
      </div>
      <Layout__UserControls user={Some(currentUser)} />
    </div>
  </div>
}
