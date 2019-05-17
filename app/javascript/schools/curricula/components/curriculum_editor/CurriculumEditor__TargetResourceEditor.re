let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("CurriculumEditor__TargetResourceEditor");

let make = _children => {
  ...component,
  render: _self =>
    /* let description =
       switch (answerOption |> AnswerOption.description) {
       | Some(value) => value
       | None => ""
       }; */
    <div>
      <label className="block tracking-wide text-gray-800 text-xs font-semibold mb-2" htmlFor="title">
        {"Resources" |> str}
      </label>
      <ul className="resources-upload-tab flex border-b">
        <li className="mr-1 resources-upload-tab__link resources-upload-tab__link--active">
          <div className="inline-block text-gray-800 hover:text-indigo-800 p-4 text-xs font-semibold"> {"Upload File" |> str} </div>
        </li>
        <li className="mr-1 resources-upload-tab__link">
          <div className="inline-block text-gray-800 p-4 text-xs hover:text-indigo-800 font-semibold">
            {"Add URL" |> str}
          </div>
        </li>
      </ul>
      <div
        className="resources-upload-tab__body p-5 border-l border-r border-b rounded rounded-tl-none rounded-tr-none">
        <input type_="file" id="file" className="input-file" multiple=true />
        <label className="flex items-center text-sm" htmlFor="file">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="17" fill="#9FB0CC" viewBox="0 0 20 17">
            <path
              d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"
            />
          </svg>
          <span className="ml-2"> {"Choose a file &hellip;" |> str} </span>
        </label>
      </div>
      <div className="flex items-center py-3 cursor-pointer">
        <svg className="svg-icon w-8 h-8" viewBox="0 0 20 20">
          <path
            fill="#A8B7C7"
            d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
          />
        </svg>
        <h5 className="font-semibold ml-2"> {"Add another resource" |> str} </h5>
      </div>
    </div>,
};
