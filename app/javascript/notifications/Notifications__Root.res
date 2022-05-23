let str = React.string

let tr = I18n.t(~scope = "components.Notifications__Root")

@react.component
let make = (
  ~wrapperClasses,
  ~buttonClasses,
  ~iconClasses,
  ~hasNotifications,
  ~title=?,
  ~icon=?,
) => {
  let (showNotifications, setShowNotifications) = React.useState(() => false)
  <div className=wrapperClasses>
    {<EditorDrawer
      size=EditorDrawer.Small
      closeButtonTitle={tr("close") ++ title->Belt.Option.getWithDefault("")}
      closeDrawerCB={() => setShowNotifications(_ => false)}>
      <Notifications__List />
    </EditorDrawer>->ReactUtils.nullUnless(showNotifications)}
    <button
      title=tr("show_notifications")
      className=buttonClasses
      onClick={_ => setShowNotifications(_ => true)}>
      <FaIcon classes={icon->Belt.Option.getWithDefault("")} />
      {str(title->Belt.Option.getWithDefault(""))}
      {ReactUtils.nullUnless(<span className=iconClasses />, hasNotifications)}
    </button>
  </div>
}
