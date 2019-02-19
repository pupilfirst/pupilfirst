let component = ReasonReact.statelessComponent("SA_StudentsPanel_StudentForm");

let str = ReasonReact.string;

let make = (~closeFormCB, _children) => {
  ...component,
  render: _self =>
    <div className="blanket">
      <div className="drawer-right">
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5 className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Student Details" |> str}
                </h5>
                <label className="block tracking-wide text-grey-darker text-xs font-semibold mb-2" htmlFor="name">
                  {"Name*  " |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="name"
                  type_="text"
                  placeholder="Student name here"
                />
                <label className="block tracking-wide text-grey-darker text-xs font-semibold mb-2">
                  {"Email*  " |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="level number"
                  type_="number"
                  placeholder="Student email here"
                />
                <div className="flex">
                  <button
                    onClick={_e => closeFormCB()}
                    className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                    {"Close" |> str}
                  </button>
                </div>
                <div className="flex">
                  <button
                    className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                    {"Add Student" |> str}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>,
};
