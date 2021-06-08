let str = React.string

@react.component
let make = (~submissionId) => {
  <div>
    <div className="bg-gray-100 pt-9 pb-8 px-3 -mt-7">
      <div className="bg-gray-100 static md:sticky md:top-0">
        <div className="max-w-3xl mx-auto">
          <div className="flex flex-col md:flex-row items-end lg:items-center py-4">
            {str("Bar")}
          </div>
        </div>
      </div>
    </div>
  </div>
}
