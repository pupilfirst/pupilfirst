let str = React.string

let renderImage = (imageSrc, alt) =>
  switch imageSrc {
  | Some(imageSrc) => <img className="mb-8 max-w-xs" src={imageSrc} alt={alt} />
  | None => React.null
  }

let renderActions = (primary, secondary) =>
  switch (primary, secondary) {
  | (Some(primary), Some(secondary)) =>
    <div className="flex gap-4 flex-wrap justify-center mt-6"> {primary} {secondary} </div>
  | (Some(primary), None) => <div className="mt-6"> {primary} </div>
  | (None, Some(secondary)) => <div className="mt-6"> {secondary} </div>
  | (None, None) => React.null
  }

@react.component
let make = (~title, ~description, ~imageSrc=?, ~primaryAction=?, ~secondaryAction=?) =>
  <div className="grid place-items-center p-6 max-w-xl">
    {renderImage(imageSrc, title)}
    <p className="text-lg font-bold mb-3"> {title->str} </p>
    <p className="text-sm text-center text-gray-700"> {description->str} </p>
    {renderActions(primaryAction, secondaryAction)}
  </div>
