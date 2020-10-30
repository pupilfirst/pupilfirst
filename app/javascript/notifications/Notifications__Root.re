let str = React.string;

[@react.component]
let make = (~wrapperClasses, ~buttonClasses, ~title=?, ~icon=?) => {
  let (showNotifications, setShowNotifications) = React.useState(() => false);
  <div className=wrapperClasses>
    {<EditorDrawer
       closeButtonTitle={"Close " ++ title->Belt.Option.getWithDefault("")}
       closeDrawerCB={() => setShowNotifications(_ => false)}>
       <div> {str("Halo")} </div>
     </EditorDrawer>
     ->ReactUtils.nullUnless(showNotifications)}
    <button
      className=buttonClasses onClick={_ => setShowNotifications(_ => true)}>
      <FaIcon classes={icon->Belt.Option.getWithDefault("")} />
      {str(title->Belt.Option.getWithDefault(""))}
    </button>
  </div>;
};
