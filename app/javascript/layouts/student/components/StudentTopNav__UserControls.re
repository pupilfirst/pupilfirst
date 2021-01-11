let str = React.string;

let showLink = (icon, text, href) => {
  <div key=href className="">
    <a
      className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200"
      href>
      <FaIcon classes={"fas fw fa-" ++ icon} />
      {str(text)}
    </a>
  </div>;
};

let links = () =>
  <div
    className="dropdown__list dropdown__list-right bg-white shadow-lg rounded mt-3 border absolute w-40 z-50">
    {showLink("pencil", "edit", "edit")}
  </div>;

[@react.component]
let make = () => {
  let (showDropdown, setShowDropdown) = React.useState(() => false);

  <button
    className="md:ml-2 h-10 w-10 rounded-full border border-gray-300 hover:border-primary-500"
    onClick={_ => setShowDropdown(s => !s)}>
    <img
      className="inline-block object-contain rounded-full"
      src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
      alt="user_name"
    />
    {ReactUtils.nullUnless(links(), showDropdown)}
  </button>;
};
