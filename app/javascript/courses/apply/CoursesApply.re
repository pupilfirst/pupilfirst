[@bs.config {jsx: 3}];
[%bs.raw {|require("./apply.css")|}];
let str = React.string;

[@react.component]
let make = (~authenticityToken) =>
  <div className="bg-gray-100 py-8">
    <div className="container mx-auto px-3 max-w-6xl">
      <div
        className="flex flex-col md:flex-row shadow-xl rounded-lg overflow-hidden bg-white border">
        <div
          className="md:w-1/2 enroll-left__container svg-bg-pattern-4 relative p-4 pt-5 md:px-14 md:py-20 lg:px-28 lg:py-32 text-white">
          <div className="">
            <h1 className="font-bold"> {"SaaS 201" |> str} </h1>
            <p>
              {
                "This course allows you to learn industry-relevant skills with up-to-date content, developed by professionals."
                |> str
              }
            </p>
          </div>
        </div>
        <div className="md:w-1/2 p-4 pt-5 md:px-14 md:py-20 lg:px-28 lg:py-32">
          <div className="flex flex-col">
            <h4 className="font-bold">
              {"Enroll to SaaS 201 course" |> str}
            </h4>
            <div className="w-full mt-4">
              <label
                className="inline-block tracking-wide text-gray-800 text-xs font-semibold">
                {"Your Name" |> str}
              </label>
              <input
                className="appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
                type_="text"
                placeholder="Type your name"
              />
            </div>
            <div className="w-full mt-4">
              <label
                className="inline-block tracking-wide text-gray-800 text-xs font-semibold">
                {"Email" |> str}
              </label>
              <input
                className="appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
                type_="text"
                placeholder="Type your email id here"
              />
            </div>
            <button className="btn btn-primary justify-center shadow-lg mt-6">
              {"Enroll to the course" |> str}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>;
