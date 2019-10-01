[@bs.config {jsx: 3}];
[%bs.raw {|require("./SkeletonLoading.css")|}];

let card = () =>
  <div className="skeleton-body-container w-full mx-auto">
    <div className="skeleton-body-wrapper px-3 lg:px-0">
      <div
        className="skeleton-placeholder__card mt-4 px-5 py-6 bg-white rounded-lg shadow">
        <div className="flex items-center">
          <div className="flex-1">
            <div
              className="skeleton-placeholder__line-sm w-5/6 skeleton-animate"
            />
            <div
              className="skeleton-placeholder__line-sm mt-4 w-4/6 skeleton-animate"
            />
          </div>
          <div
            className="skeleton-placeholder__line-sm w-1/6 skeleton-animate"
          />
        </div>
      </div>
    </div>
  </div>;

let multiple = (~count, ~element) =>
  Array.make(count, element)
  |> Array.mapi((key, element) =>
       <div key={key |> string_of_int}> element </div>
     )
  |> React.array;

/* <div className="bg-gray-200 pt-6 px-2 pb-2 mt-6 shadow rounded-lg">
          <h5 className="ml-1">Skeleton Loading</h5>
          <div className="border p-6 rounded-lg mt-2">
            <p className="text-xs font-semibold">Target Card</p>
            <div className="skeleton-body-container w-full pb-4 mx-auto">
              <div className="skeleton-body-wrapper px-3 lg:px-0">
                <div className="skeleton-placeholder__card mt-6 px-5 py-6 bg-white rounded-lg shadow">
                  <div className="flex items-center">
                    <div className="flex-1">
                      <div className="skeleton-placeholder__line-sm w-5/6 skeleton-animate"></div>
                      <div className="skeleton-placeholder__line-sm mt-4 w-4/6 skeleton-animate"></div>
                      </div>
                    <div className="skeleton-placeholder__line-sm w-1/6 skeleton-animate"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="bg-white border p-6 rounded-lg mt-2">
            <p className="text-xs font-semibold">Title and subtitle</p>
            <div className="skeleton-body-container w-full pb-4 mx-auto">
              <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
                <div className="skeleton-placeholder__line-md mt-4 w-3/6 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 w-4/6 skeleton-animate"></div>
              </div>
            </div>
          </div>
          <div className="bg-white border p-6 rounded-lg mt-2">
            <p className="text-xs font-semibold">Code</p>
            <div className="skeleton-body-container w-full pb-4 mx-auto">
              <div className="skeleton-body-wrapper max-w-xs mt-8 px-3 lg:px-0">
                <div className="flex skeleton-placeholder__code-line">
                  <div className="skeleton-placeholder__line-sm mr-3 w-2/6 skeleton-animate"></div>
                  <div className="skeleton-placeholder__line-sm mr-3 w-2/6 skeleton-animate"></div>
                  <div className="skeleton-placeholder__line-sm mr-3 w-4 skeleton-animate"></div>
                </div>
                <div className="flex skeleton-placeholder__code-line ml-6">
                  <div className="skeleton-placeholder__line-sm mt-4 mr-3 w-3/6 skeleton-animate"></div>
                  <div className="skeleton-placeholder__line-sm mt-4 mr-3 w-3/6 skeleton-animate"></div>
                </div>
                <div className="flex skeleton-placeholder__code-line ml-6">
                  <div className="skeleton-placeholder__line-sm mt-4 mr-3 w-2/6 skeleton-animate"></div>
                  <div className="skeleton-placeholder__line-sm mt-4 mr-3 w-1/6 skeleton-animate"></div>
                  <div className="skeleton-placeholder__line-sm mt-4 mr-3 w-2/6 skeleton-animate"></div>
                </div>
                <div className="flex skeleton-placeholder__code-line">
                  <div className="skeleton-placeholder__line-sm mt-4 mr-3 w-16 skeleton-animate"></div>
                  <div className="skeleton-placeholder__line-sm mt-4 mr-3 w-6 skeleton-animate"></div>
                </div>
              </div>
            </div>
          </div>
          <div className="bg-white border p-6 rounded-lg mt-2">
            <p className="text-xs font-semibold">Profile Card</p>
            <div className="skeleton-body-container w-full pb-4 mx-auto">
              <div className="skeleton-body-wrapper max-w-sm mt-8 px-3 lg:px-0">
                <div className="flex items-center">
                  <div className="w-14 h-14 bg-gray-100 rounded-full mr-4 skeleton-animate"></div>
                  <div className="flex-1">
                    <div className="skeleton-placeholder__line-md w-3/6 skeleton-animate"></div>
                    <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="bg-white border p-6 rounded-lg mt-2">
            <p className="text-xs font-semibold">Image</p>
            <div className="skeleton-body-container w-full pb-4 mx-auto">
              <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
                <div className="skeleton-placeholder__image mt-5 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mx-auto mt-4 w-3/6 skeleton-animate"></div>
              </div>
            </div>
          </div>
          <div className="bg-white border p-6 rounded-lg mt-2">
            <p className="text-xs font-semibold">Paragraph</p>
            <div className="skeleton-body-container w-full pb-4 mx-auto">
              <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
                <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 w-4/6 skeleton-animate"></div>
              </div>
            </div>
          </div>
          <div className="bg-white border p-6 rounded-lg mt-2">
            <p className="text-xs font-semibold">Learn content</p>
            <div className="skeleton-body-container w-full pb-4 mx-auto">
              <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
                <div className="skeleton-placeholder__line-md mt-4 w-3/6 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 w-4/6 skeleton-animate"></div>
                <div className="skeleton-placeholder__image mt-5 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mx-auto mt-4 w-3/6 skeleton-animate"></div>
              </div>
              <div className="skeleton-body-wrapper mt-8 px-3 lg:px-0">
                <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 skeleton-animate"></div>
                <div className="skeleton-placeholder__line-sm mt-4 w-4/6 skeleton-animate"></div>
              </div>
            </div







          </   </div> */
