let str = React.string

let defaultCTA = {
  <p className="mt-2 mb-3 text-sm leading-normal"> {str("Try heading back?")} </p>
}

@react.component
let make = (
  ~heading="The page you were looking for doesn't exist!",
  ~description="You may have mistyped the address, or the page may have moved.",
  ~cta=defaultCTA,
) =>
  <div className="flex flex-1 w-full h-full bg-red-200 items-center justify-center">
    <div className="max-w-3xl mx-auto text-center px-4 pb-4">
      <h1 className="text-3xl font-bold"> {str(heading)} </h1>
      <p className="mt-3 text-md leading-normal"> {str(description)} </p>
      {cta}
    </div>
  </div>
