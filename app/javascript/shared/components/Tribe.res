@react.component
let make = (~id, ~kind, ~slug) => {
  let widgetId = "community-widget-" ++ id

  React.useEffect1(() => {
    TribeUtils.tribe(widgetId, kind, slug)
    None
  }, [])

  <div id={ widgetId } />
}
