[@bs.config {jsx: 3}];

[%bs.raw {|require("./PfIcon__Example.css")|}];

let str = React.string;

module Example = {
  let icons = [|
    "plus-circle",
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
    <div className="max-w-5xl mx-auto">
      <h1 className="text-center text-2xl font-bold pt-4">
        {"pf-icon" |> str}
      </h1>
      <div
        className="mx-2 mt-4 flex md:flex-row flex-col flex-wrap bg-white border rounded px-2">
        {icons
         |> Array.map(icon => {
              let iconClasses = "if i-" ++ icon;
              <div
                key=icon
                className="flex items-center mt-4 md:w-1/2 w-full px-2">
                <PfIcon className={iconClasses ++ " if-fw text-2xl"} />
                <div className="ml-4 overflow-x-auto">
                  <div className="font-semibold text-xl"> {icon |> str} </div>
                  <div className="overflow-x-auto">
                    <code
                      className="inline-block text-gray-900 text-xs bg-red-100 p-1 mt-px whitespace-no-wrap">
                      {"<PfIcon className=\""
                       ++ iconClasses
                       ++ " if-fw\" />"
                       |> str}
                    </code>
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
