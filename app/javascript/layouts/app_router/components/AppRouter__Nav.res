exception UnknownPathEncountered(list<string>)
let str = React.string

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let (sidebarOpen, setSidebarOpen) = React.useState(_ => false)
  [
    ReactUtils.nullUnless(
      <div className="fixed inset-0 flex z-40 md:hidden">
        <div>
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div>
              <div className="absolute top-0 right-0 -mr-12 pt-2">
                <button
                  className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                  onClick={_e => setSidebarOpen(_ => false)}>
                  <span className="sr-only"> {str("Close sidebar")} </span>
                </button>
              </div>
            </div>
            <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
              <div className="flex-shrink-0 flex items-center px-4">
                <img className="h-8 w-auto" src="#" alt="School Name" />
              </div>
              <nav className="mt-5 px-2 space-y-1" />
            </div>
          </div>
        </div>
        <div className="flex-shrink-0 w-14" />
      </div>,
      sidebarOpen,
    ),
    <div className="hidden md:flex md:flex-shrink-0">
      <div className="flex flex-col w-64">
        <div className="flex flex-col h-0 flex-1 border-r border-gray-200 bg-white">
          <div className="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
            <div className="flex items-center flex-shrink-0 px-4">
              <img className="h-8 w-auto" src="#" alt="School Name" />
            </div>
            <nav className="mt-5 flex-1 px-2 bg-white space-y-1" />
          </div>
        </div>
      </div>
    </div>,
  ]->React.array
}
