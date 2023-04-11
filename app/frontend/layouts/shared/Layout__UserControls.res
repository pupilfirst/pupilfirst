open SchoolRouter__Types

let str = React.string

let t = I18n.t(~scope="components.Layout__UserControls")

let showLink = (icon, text, href) => {
  <div key=href className="whitespace-nowrap">
    <a
      rel="nofollow"
      className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50"
      href>
      <FaIcon classes={"fas fw fa-" ++ icon} /> <span className="ps-2 "> {str(text)} </span>
    </a>
  </div>
}

let links = () => {
  [
    showLink("edit", t("edit_profile"), "/user/edit"),
    showLink("power-off", t("sign_out"), "/users/sign_out"),
  ]
}

let selected = user => {
  <button
    title={t("user_controls")}
    className="md:ms-2 h-10 w-10 rounded-full border-2 border-gray-300 hover:border-primary-500 focus:outline-none focus:border-primary-500 ">
    {User.avatarUrl(user)->Belt.Option.mapWithDefault(
      <Avatar
        name={User.name(user)} className="inline-block object-contain rounded-full text-tiny"
      />,
      src =>
        <img
          className="inline-block object-contain rounded-full text-tiny" src alt={User.name(user)}
        />,
    )}
  </button>
}

@react.component
let make = (~user, ~right=true) => {
  switch user {
  | Some(user) => <Dropdown selected={selected(user)} contents={links()} right />
  | None => React.null
  }
}
