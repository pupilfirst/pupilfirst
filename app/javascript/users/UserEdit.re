[%bs.raw {|require("./UserEdit.css")|}];

let str = React.string;

[@react.component]
let make = (~userData) => {
  <div className="container mx-auto px-3 py-8 max-w-5xl">
    <div className="bg-white shadow sm:rounded-lg">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold">
              {"Edit your profile" |> str}
            </h3>
            <p className="mt-1 text-sm text-gray-700">
              {"This information will be displayed publicly so be careful what you share."
               |> str}
            </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <div className="">
              <div className="">
                <label
                  htmlFor="user_name" className="block text-sm font-semibold">
                  {"Name" |> str}
                </label>
              </div>
            </div>
            <input
              id="user_name"
              className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
              placeholder="Type your name"
            />
            <div className="mt-6">
              <label htmlFor="about" className="block text-sm font-semibold">
                {"About" |> str}
              </label>
              <div>
                <textarea
                  id="about"
                  rows=3
                  className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
                  placeholder="A brief introduction about yourself"
                />
              </div>
            </div>
            <div className="mt-6">
              <label className="block text-sm font-semibold">
                {"Photo" |> str}
              </label>
              <div className="mt-2 flex items-center">
                <span
                  className="inline-block h-14 w-14 rounded-full overflow-hidden bg-gray-200 border-2 boder-gray-400"
                />
                <span className="ml-5 rounded-md shadow-sm">
                  <button
                    className="py-2 px-3 border border-gray-400 rounded-md text-sm font-semibold hover:text-gray-800 focus:outline-none active:bg-gray-100 active:text-gray-800">
                    {"Change photo" |> str}
                  </button>
                </span>
              </div>
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold"> {"Security" |> str} </h3>
            <p className="mt-1 text-sm text-gray-700">
              {"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vitae tellus."
               |> str}
            </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold">
              {"Change your current password" |> str}
            </p>
            <div className="mt-6">
              <label
                htmlFor="current_password"
                className="block text-sm font-semibold">
                {"Current Password" |> str}
              </label>
              <input
                type_="password"
                id="current_password"
                className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
                placeholder="Type current password"
              />
            </div>
            <div className="mt-6">
              <label
                htmlFor="new_password" className="block text-sm font-semibold">
                {"New Password" |> str}
              </label>
              <input
                type_="password"
                id="new_password"
                className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
                placeholder="Type new password"
              />
            </div>
            <div className="mt-6">
              <label
                htmlFor="confirm_password"
                className="block text-sm font-semibold">
                {"Confirm password" |> str}
              </label>
              <input
                type_="password"
                id="confirm_password"
                className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
                placeholder="Confirm new password"
              />
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold">
              {"Notifications" |> str}
            </h3>
            <p className="mt-1 text-sm text-gray-700">
              {"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vitae tellus."
               |> str}
            </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold"> {"Community Digest" |> str} </p>
            <p className="text-sm text-gray-700">
              {"Community digest emails contain new questions from your communities, and a selection of unanswered questions from the past week."
               |> str}
            </p>
            <div className="mt-6">
              <div className="flex items-center">
                <input
                  id="daily_mail"
                  name="community_digest"
                  type_="radio"
                  className="form-radio focus:outline-none h-4 w-4 text-primary-500"
                />
                <label htmlFor="daily_mail" className="ml-3">
                  <span className="block text-sm leading-5 font-semibold">
                    {"Send me a daily mail" |> str}
                  </span>
                </label>
              </div>
              <div className="mt-4 flex items-center">
                <input
                  id="disable_mail"
                  name="community_digest"
                  type_="radio"
                  className="form-radio focus:outline-none h-4 w-4 text-primary-500"
                />
                <label htmlFor="disable_mail" className="ml-3">
                  <span className="block text-sm font-semibold">
                    {"Disable" |> str}
                  </span>
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div
        className="bg-gray-100 px-4 py-5 sm:p-6 flex rounded-b-lg justify-end">
        <button className="btn btn-primary"> {"Save Changes" |> str} </button>
      </div>
    </div>
    <div className="bg-white shadow sm:rounded-lg mt-10">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold"> {"Account" |> str} </h3>
            <p className="mt-1 text-sm text-gray-700">
              {"Nunc id massa ultricies, hendrerit nibh ac, consequat nisl."
               |> str}
            </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold text-red-700">
              {"Delete account" |> str}
            </p>
            <p className="text-sm text-gray-700 mt-1">
              {"Duis consectetur aliquam justo vitae sodales. Mauris vitae lectus id tellus blandit luctus et non leo. Nunc id massa ultricies, hendrerit nibh ac, consequat nisl."
               |> str}
            </p>
            <div className="mt-4">
              <button
                className="py-2 px-3 border border-red-500 text-red-600 rounded text-xs font-semibold hover:bg-red-600 hover:text-white focus:outline-none active:bg-red-700 active:text-white">
                {"Delete your account" |> str}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>;
};
