@react.component
let make = () => {
    <button onClick={_ => DomUtils.goBack()} className="bg-gray-100 border border-gray-300 text-sm block px-3 py-1 rounded-full">
    <i className="if i-arrow-left-regular if-fw inline-block me-1" ></i>
    {"back" -> React.string }
    </button>
}
