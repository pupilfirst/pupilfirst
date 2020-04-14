let str = React.string;

let avatarClasses = size => {
  let (defaultSize, mdSize) = size;
  "w-"
  ++ defaultSize
  ++ " h-"
  ++ defaultSize
  ++ " md:w-"
  ++ mdSize
  ++ " md:h-"
  ++ mdSize
  ++ " text-xs rounded-full overflow-hidden flex-shrink-0 object-cover";
};

let avatar = (~size=("9", "9"), avatarUrl, name) => {
  switch (avatarUrl) {
  | Some(avatarUrl) => <img className={avatarClasses(size)} src=avatarUrl />
  | None => <Avatar name className={avatarClasses(size)} />
  };
};

[@react.component]
let make = (~user, ~createdAt) =>
  <div>
    <p className="text-xs text-gray-800">
      {createdAt |> DateFns.format("Do MMMM, YYYY HH:mm") |> str}
    </p>
    <div
      className="p-2 flex flex-row items-center bg-gray-100 text-gray-900 border rounded-lg mt-1">
      <div
        className="w-9 h-9 rounded-full bg-gray-500 text-white border border-gray-400 flex items-center justify-center flex-shrink-0 overflow-hidden">
        {avatar(~size=("9", "9"), user |> User.avatarUrl, user |> User.name)}
      </div>
      <div className="pl-2">
        <p className="font-semibold text-xs"> {user |> User.name |> str} </p>
        <p className="text-xs leadig-normal"> {user |> User.title |> str} </p>
      </div>
    </div>
  </div>;
