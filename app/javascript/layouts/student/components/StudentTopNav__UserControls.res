let str = React.string

let showLink = (icon, text, href) => {
  <div key=href className="">
    <a
      rel="nofollow"
      className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200"
      href>
      <FaIcon classes={"fas fw fa-" ++ icon} /> <span className="pl-2"> {str(text)} </span>
    </a>
  </div>
}

let links = () => {
  [
    showLink("edit", "Edit Profile", "/user/edit"),
    showLink("power-off", "Sign-out", "/users/sign_out"),
  ]
}

let selected = user => {
  <button
    className="md:ml-2 h-10 w-10 rounded-full border border-gray-300 hover:border-primary-500">
    {user->Belt.Option.mapWithDefault(
      <Avatar name="Unknown User" className="inline-block object-contain rounded-full" />,
      u =>
        User.avatarUrl(u)->Belt.Option.mapWithDefault(
          <Avatar name={User.name(u)} className="inline-block object-contain rounded-full" />,
          src =>
            <img className="inline-block object-contain rounded-full" src alt={User.name(u)} />,
        ),
    )}
  </button>
}

@react.component
let make = (~user) => {
  <Dropdown selected={selected(user)} contents={links()} right=true />
}
