%%raw(`import "./SkeletonLoading.css"`)

let card = (~className="", ()) =>
  <div className={"skeleton-body-container pt-4 w-full mx-auto" ++ className}>
    <div className="skeleton-body-wrapper px-3 lg:px-0">
      <div className="skeleton-placeholder__card px-5 py-6 bg-white rounded-lg shadow">
        <div className="flex items-center">
          <div className="flex-1">
            <div className="skeleton-placeholder__line-sm w-5/6 skeleton-animate" />
            <div className="skeleton-placeholder__line-sm mt-4 w-2/3 skeleton-animate" />
          </div>
          <div className="skeleton-placeholder__line-sm w-1/6 skeleton-animate" />
        </div>
      </div>
    </div>
  </div>

let userCard = () =>
  <div className="skeleton-body-container pt-4 w-full mx-auto">
    <div className="skeleton-body-wrapper px-2 lg:px-0">
      <div className="skeleton-placeholder__card px-5 py-6 bg-white rounded-lg shadow">
        <div className="flex items-center">
          <div className="w-14 h-14 bg-gray-50 rounded-full me-4 skeleton-animate" />
          <div className="flex-1">
            <div className="skeleton-placeholder__line-sm w-1/3 skeleton-animate" />
            <div className="skeleton-placeholder__line-sm mt-4 w-1/2 skeleton-animate" />
          </div>
          <div className="skeleton-placeholder__line-sm w-1/6 skeleton-animate" />
        </div>
      </div>
    </div>
  </div>

let userDetails = () =>
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="skeleton-body-wrapper max-w-sm mt-8 px-3 lg:px-0">
      <div className="flex items-center">
        <div className="w-14 h-14 bg-gray-50 rounded-full me-4 skeleton-animate" />
        <div className="flex-1">
          <div className="skeleton-placeholder__line-sm w-1/2 skeleton-animate" />
          <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
        </div>
      </div>
    </div>
  </div>

let heading = () =>
  <div className="skeleton-body-container pt-8 w-full pb-4 mx-auto">
    <div className="skeleton-body-wrapper space-y-4 px-3 lg:px-0">
      <div className="skeleton-placeholder__line-md w-1/2 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm skeleton-animate" />
      <div className="skeleton-placeholder__line-sm w-2/3 skeleton-animate" />
    </div>
  </div>

@live
let codeBlock = () =>
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="skeleton-body-wrapper max-w-xs mt-8 px-3 lg:px-0">
      <div className="flex">
        <div className="skeleton-placeholder__line-sm me-3 w-1/3 skeleton-animate" />
        <div className="skeleton-placeholder__line-sm me-3 w-1/3 skeleton-animate" />
        <div className="skeleton-placeholder__line-sm me-3 w-4 skeleton-animate" />
      </div>
      <div className="flex ms-6">
        <div className="skeleton-placeholder__line-sm mt-4 me-3 w-1/2 skeleton-animate" />
        <div className="skeleton-placeholder__line-sm mt-4 me-3 w-1/2 skeleton-animate" />
      </div>
      <div className="flex ms-6">
        <div className="skeleton-placeholder__line-sm mt-4 me-3 w-1/3 skeleton-animate" />
        <div className="skeleton-placeholder__line-sm mt-4 me-3 w-1/6 skeleton-animate" />
        <div className="skeleton-placeholder__line-sm mt-4 me-3 w-1/3 skeleton-animate" />
      </div>
      <div className="flex">
        <div className="skeleton-placeholder__line-sm mt-4 me-3 w-16 skeleton-animate" />
        <div className="skeleton-placeholder__line-sm mt-4 me-3 w-6 skeleton-animate" />
      </div>
    </div>
  </div>

let image = () =>
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
      <div className="skeleton-placeholder__image mt-5 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mx-auto mt-4 w-1/2 skeleton-animate" />
    </div>
  </div>

let imageCard = () =>
  <div className="skeleton-body-container pt-4 w-full mx-auto">
    <div className="skeleton-body-wrapper">
      <div className="skeleton-placeholder__card bg-white rounded-lg shadow grid grid-cols-2 gap-5">
        <div className="p-5">
          <div className="skeleton-placeholder__line-sm mt-4 w-1/2 skeleton-animate" />
          <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
          <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
          <div className="skeleton-placeholder__line-sm mt-4 w-2/3 skeleton-animate" />
          <div className="flex gap-5 mt-8">
            <div className="h-10 w-1/2 bg-gray-200 skeleton-animate" />
            <div className="h-10 w-1/2 bg-gray-200 skeleton-animate" />
          </div>
        </div>
        <div className="p-5">
          <div className="skeleton-placeholder__image skeleton-animate" />
        </div>
      </div>
    </div>
  </div>

let paragraph = () =>
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
      <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mt-4 w-2/3 skeleton-animate" />
    </div>
  </div>

let input = () =>
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="skeleton-placeholder__line-sm mt-4 w-1/4 skeleton-animate" />
    <div className="p-4 mt-2 bg-white border border-gray-300 rounded-md">
      <div className="skeleton-placeholder__line-sm skeleton-animate" />
    </div>
  </div>

let button = () =>
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="p-4 mt-2 bg-gray-200 border border-gray-300 rounded-md flex justify-center">
      <div className="skeleton-placeholder__line-sm w-1/4 skeleton-animate" />
    </div>
  </div>

let singleLink = () => {
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="skeleton-placeholder__line-md mt-4 skeleton-animate" />
  </div>
}

let secondaryLink = () => {
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="skeleton-placeholder__line-lg mt-2 skeleton-animate" />
  </div>
}

let contents = () =>
  <div className="skeleton-body-container w-full pb-4 mx-auto">
    <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
      <div className="skeleton-placeholder__line-md mt-4 w-1/2 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mt-4 w-2/3 skeleton-animate" />
      <div className="skeleton-placeholder__image mt-5 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mx-auto mt-4 w-1/2 skeleton-animate" />
    </div>
    <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
      <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate" />
      <div className="skeleton-placeholder__line-sm mt-4 w-2/3 skeleton-animate" />
    </div>
  </div>

let calendar = () =>
  <div className="grid grid-cols-7 relative z-30 grid-rows-5 gap-1 mt-2">
    <div className="skeleton-placeholder__date skeleton-animate col-start-4" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
    <div className="skeleton-placeholder__date skeleton-animate" />
  </div>

let coursePage = () => {
  <div>
    <div className="bg-gray-50 pb-8">
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
        <div className="skeleton-body-wrapper pt-10 px-3 lg:px-0">
          <div className="skeleton-placeholder__line-md w-1/12 skeleton-animate" />
        </div>
        {heading()}
      </div>
    </div>
    <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 pt-4">
      <div> {input()} </div>
      <div> {input()} </div>
      <div> {input()} </div>
      <div> {button()} </div>
    </div>
  </div>
}

let multiple = (~count, ~element) =>
  Array.make(count, element)
  |> Array.mapi((key, element) => <div key={key |> string_of_int}> element </div>)
  |> React.array
