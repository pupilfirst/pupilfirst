let str = React.string

@react.component
let make = (~wrapperClasses, ~buttonClasses, ~title=?, ~icon=?) => {
  let (showNotifications, setShowNotifications) = React.useState(() => false)
  <div className=wrapperClasses>
    {<EditorDrawer
      size=EditorDrawer.Small
      closeButtonTitle={"Close " ++ title->Belt.Option.getWithDefault("")}
      closeDrawerCB={() => setShowNotifications(_ => false)}>
      <Notifications__List />
    </EditorDrawer>->ReactUtils.nullUnless(showNotifications)}
    <button className=buttonClasses onClick={_ => setShowNotifications(_ => true)}>
      <FaIcon classes={icon->Belt.Option.getWithDefault("")} />
      {str(title->Belt.Option.getWithDefault(""))}
      <span
        className="student-navbar__notifications-unread-bullet absolute block h-3 w-3 rounded-full border-2 border-white bg-red-500"
      />
    </button>
  </div>
}
