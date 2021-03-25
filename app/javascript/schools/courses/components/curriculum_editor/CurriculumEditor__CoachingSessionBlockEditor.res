let str = React.string

@react.component
let make = () => {
  <div className="relative border border-gray-400 rounded-lg">
    <div
      className="content-block__content text-base bg-gray-200 flex justify-center items-center rounded-t-lg">
      <div className="w-full">
        <div
          className="flex justify-between items-center bg-white rounded-t-lg px-6 py-4 hover:bg-gray-100 hover:text-primary-500">
          <div className="flex items-center">
            <FaIcon classes="text-4xl text-gray-800 far fa-file-alt" />
            <div className="pl-4 leading-tight h-12 flex flex-col justify-center">
              <div className="text-lg font-semibold"> {"Schedule coaching session" |> str} </div>
              <div className="text-sm italic text-gray-600"> {"The scheduling component will be visible here." |> str} </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
}
