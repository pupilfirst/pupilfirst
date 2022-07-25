let str = React.string

@react.component
let make = () => {
  <div>
    <div className="bg-gray-50 border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"Card"->str} </p> {SkeletonLoading.card()}
    </div>
    <div className="bg-gray-50 border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"User Card"->str} </p> {SkeletonLoading.userCard()}
    </div>
    <div className="bg-white border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"User Details"->str} </p>
      {SkeletonLoading.userDetails()}
    </div>
    <div className="bg-white border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"Heading"->str} </p> {SkeletonLoading.heading()}
    </div>
    <div className="bg-white border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"Code Block"->str} </p> {SkeletonLoading.codeBlock()}
    </div>
    <div className="bg-white border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"Image"->str} </p> {SkeletonLoading.image()}
    </div>
    <div className="bg-gray-50 border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"Image Card"->str} </p> {SkeletonLoading.imageCard()}
    </div>
    <div className="bg-white border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"Paragraph"->str} </p> {SkeletonLoading.paragraph()}
    </div>
    <div className="bg-white border p-6 rounded-lg mt-2">
      <p className="text-xs font-semibold"> {"Contents"->str} </p> {SkeletonLoading.contents()}
    </div>
  </div>
}
