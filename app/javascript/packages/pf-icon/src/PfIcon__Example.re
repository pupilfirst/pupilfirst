[@bs.config {jsx: 3}];

[%bs.raw {|require("./PfIcon__Example.css")|}];

let str = React.string;

module Icon = PfIcon__Icon;

module Example = {
  let icons = [|
    "plus-circle",
    "default",
    "lamp-solid",
    "check-light",
    "times-light",
    "badge-check-solid",
    "badge-check-regular",
    "badge-check-light",
    "writing-pad-solid",
    "eye-solid",
    "users-solid",
    "users-regular",
    "users-light",
    "ellipsis-h-solid",
    "ellipsis-h-regular",
    "ellipsis-h-light",
    "check-square-alt-solid",
    "check-square-alt-regular",
    "check-square-alt-light",
    "check-square-solid",
    "check-square-regular",
    "check-square-light",
    "comment-alt-solid",
    "comment-alt-regular",
    "comment-alt-light",
    "tachometer-solid",
    "tachometer-regular",
    "tachometer-light",
    "user-check-solid",
    "user-check-regular",
    "user-check-light",
    "users-check-solid",
    "users-check-regular",
    "users-check-light",
    "sort-alpha-down-solid",
    "sort-alpha-down-regular",
    "sort-alpha-down-light",
    "clock-solid",
    "clock-regular",
    "clock-light",
  |];

  [@react.component]
  let make = () => {
    <div className="max-w-md w-full mx-auto p-6 bg-white border shadow">
      <h1 className="text-center text-2xl font-bold"> {"pf-icon" |> str} </h1>
      <div className="mt-4">
        {icons
         |> Array.map(icon => {
              let iconClasses = "text-2xl if i-" ++ icon;
              <div key=icon className="flex items-center mt-4">
                <Icon className=iconClasses />
                <div className="ml-4">
                  <div className="font-semibold text-xl"> {icon |> str} </div>
                  <div className="text-gray-900  text-sm">
                    {"< " ++ iconClasses ++ " />" |> str}
                  </div>
                </div>
              </div>;
            })
         |> React.array}
      </div>
    </div>;
  };
};

ReactDOMRe.renderToElementWithId(<Example />, "root");
