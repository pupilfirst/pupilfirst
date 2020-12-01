let str = React.string

@react.component
let make = (
  ~title,
  ~body,
  ~confirmButtonText,
  ~cancelButtonText,
  ~onConfirm,
  ~onCancel,
  ~disableConfirm,
  ~alertType=#Normal,
) => {
  let (alertBgClass, alertTextClass, buttonClasses) = switch alertType {
  | #Normal => ("bg-green-200", "text-green-600", "btn btn-success")
  | #Critical => ("bg-red-200", "text-red-600", "btn btn-danger")
  }
  <div
    className="fixed bottom-0 inset-x-0 z-50 px-4 pb-4 sm:inset-0 sm:flex sm:items-center sm:justify-center">
    <div className="fixed inset-0">
      <div className="absolute inset-0 bg-gray-800 opacity-75" />
    </div>
    <div
      className="relative z-50 bg-white rounded-lg px-4 pt-5 pb-4 overflow-hidden shadow-xl sm:max-w-lg sm:w-full sm:p-6"
      role="dialog"
      ariaModal=true
      ariaLabelledby="modal-headline">
      <div className="sm:flex sm:items-start">
        <div
          className={"mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full sm:mx-0 sm:h-10 sm:w-10 " ++
          alertBgClass}>
          <svg
            className={"h-6 w-6 " ++ alertTextClass}
            stroke="currentColor"
            fill="none"
            viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            />
          </svg>
        </div>
        <div className="mt-3 sm:mt-0 sm:ml-4">
          <h3 className="text-lg text-center sm:text-left font-semibold" id="modal-headline">
            {title |> str}
          </h3>
          <div className="mt-2"> body </div>
        </div>
      </div>
      <div className="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
        <span className="flex w-full rounded-md shadow-sm sm:ml-3 sm:w-auto">
          <button
            disabled=disableConfirm
            onClick={event => {
              ReactEvent.Mouse.preventDefault(event)
              onConfirm()
            }}
            type_="button"
            className={buttonClasses ++ " w-full"}>
            {confirmButtonText |> str}
          </button>
        </span>
        <span className="mt-3 flex w-full rounded-md shadow-sm sm:mt-0 sm:w-auto">
          <button
            onClick={event => {
              ReactEvent.Mouse.preventDefault(event)
              onCancel()
            }}
            type_="button"
            className="inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-sm font-semibold text-gray-700 hover:bg-gray-100 hover:text-gray-600 focus:outline-none">
            {cancelButtonText |> str}
          </button>
        </span>
      </div>
    </div>
  </div>
}
