let str = React.string

let avatarClasses = "w-9 h-9 md:w-9 md:h-9 text-xs rounded-full overflow-hidden flex-shrink-0 object-cover"

let avatar = (avatarUrl, name) =>
  switch avatarUrl {
  | Some(avatarUrl) => <img className=avatarClasses src=avatarUrl />
  | None => <Avatar name className=avatarClasses />
  }

@react.component
let make = (~user, ~createdAt) => {
  let (name, avatarUrl, title) = switch user {
  | Some(user) => (User.name(user), User.avatarUrl(user), User.title(user))
  | None => ("Unknown", None, "Unknown")
  }
  <div>
    <p className="hidden lg:block text-xs text-gray-800">
      {createdAt->DateFns.format("do MMMM, yyyy HH:mm") |> str}
    </p>
    <div
      className="pl-0 py-2 lg:p-2 flex flex-row items-center lg:bg-gray-100 lg:border rounded-lg lg:mt-1">
      <div
        className="w-9 h-9 rounded-full bg-gray-500 text-white border border-gray-400 flex items-center justify-center flex-shrink-0 overflow-hidden">
        {avatar(avatarUrl, name)}
      </div>
      <div className="pl-2">
        <p className="font-semibold text-xs"> {name |> str} </p>
        <p className="text-xs leadig-normal"> {title |> str} </p>
      </div>
    </div>
    <p className="block lg:hidden pb-2 text-xs text-gray-800">
      {createdAt->DateFns.format("do MMMM, yyyy HH:mm") |> str}
    </p>
  </div>
}
