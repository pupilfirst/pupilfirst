@module("../images/page-not-found.svg")
external pageNotFoundSVG: string = "default"

let str = React.string

let defaultCTA = {
  <Link href="/school" className="btn btn-primary mt-2 mb-3 text-sm leading-normal">
    {str("Back to home")}
  </Link>
}

@react.component
let make = (
  ~heading="Oops! Something went wrong.",
  ~description="Sorry, The page you are looking for doesn't exist or has been moved. Try heading back or",
  ~cta=defaultCTA,
) =>
  <div className="flex flex-1 w-full h-full bg-gray-100 items-center justify-center">
    <div className="flex flex-col items-center max-w-3xl mx-auto text-center px-4 pb-4">
      <img className="w-64 h-64" src={pageNotFoundSVG} alt={"Page not found"} />
      <h1 className="text-3xl font-bold mt-8"> {str(heading)} </h1>
      <p className="mt-3 text-md leading-normal"> {str(description)} </p>
      <div className="mt-6"> {cta} </div>
    </div>
  </div>
