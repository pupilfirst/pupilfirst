%bs.raw(`require("./UserSessionNew.css")`)

@bs.module
external federatedSignInIcon: string = "./images/federated-sign-in-icon.svg"

let str = React.string

type omniauthProvider =
  | Google
  | Facebook
  | Github
  | Developer

let federatedLoginUrl = (oauthHost, fqdn, provider) =>
  "//" ++
  (oauthHost ++
  ("/oauth/" ++
  (switch provider {
  | Google => "google"
  | Facebook => "facebook"
  | Github => "github"
  | Developer => "developer"
  } ++
  ("?fqdn=" ++ fqdn))))

let buttonText = provider =>
  "Continue " ++
  switch provider {
  | Google => "with Google"
  | Facebook => "with Facebook"
  | Github => "with Github"
  | Developer => "as Developer"
  }

let buttonClasses = provider =>
  "flex justify-center items-center px-3 py-2 leading-snug border border-transparent rounded-lg cursor-pointer font-semibold mt-4 w-full " ++
  switch provider {
  | Facebook => "federated-sigin-in__facebook-btn hover:bg-blue-800 text-white"
  | Github => "federated-sigin-in__github-btn hover:bg-black text-white"
  | Google => "federated-sigin-in__google-btn hover:bg-red-600 text-white"
  | Developer => "bg-green-100 border-green-400 text-green-800 hover:bg-green-200"
  }

let iconClasses = provider =>
  switch provider {
  | Google => "fab fa-google"
  | Facebook => "fab fa-facebook-f mr-1"
  | Github => "fab fa-github"
  | Developer => "fas fa-laptop-code"
  }

let providers = () => {
  let defaultProvides = [Google, Facebook, Github]
  DomUtils.isDevelopment() ? defaultProvides |> Array.append([Developer]) : defaultProvides
}
let renderFederatedlogin = (fqdn, oauthHost) =>
  <div className="flex flex-col pb-5 md:px-9 items-center max-w-sm mx-auto">
    {providers()
    |> Array.map(provider =>
      <a
        key={buttonText(provider)}
        className={buttonClasses(provider)}
        href={federatedLoginUrl(oauthHost, fqdn, provider)}
        rel="nofollow">
        <span className="w-1/5 text-right text-lg">
          <FaIcon classes={iconClasses(provider)} />
        </span>
        <span className="w-4/5 pl-3 text-left"> {buttonText(provider) |> str} </span>
      </a>
    )
    |> React.array}
  </div>

@react.component
let make = (~schoolName, ~fqdn, ~oauthHost) => {
  <div className="bg-gray-100 sm:py-10">
    <div className="container mx-auto max-w-lg px-4 py-6 sm:py-8 bg-white rounded-lg shadow">
      <img className="mx-auto w-32 sm:w-42" src=federatedSignInIcon />
      <div className="max-w-sm mx-auto text-lg sm:text-2xl font-bold text-center mt-4">
        {"Sign in to " ++ schoolName |> str}
      </div>
      {switch oauthHost {
      | Some(oauthHost) => renderFederatedlogin(fqdn, oauthHost)
      | None => React.null
      }}
      {<div className="max-w-sm mx-auto md:px-9">
        {switch oauthHost {
        | Some(_oauthHost) =>
          <span
            className="federated-signin-in__seperator block relative z-10 text-center text-xs text-gray-600 font-semibold">
            <span className="bg-white px-2"> {"OR" |> str} </span>
          </span>
        | None => React.null
        }}
        <a
          href="/users/sign_in_with_email"
          className="flex justify-center items-center px-3 py-2 leading-snug border border-gray-400 text-primary-500 hover:bg-gray-100 hover:border-primary-500 focus:bg-gray-200 focus::border-primary-500 focus:outline-none rounded-lg cursor-pointer font-semibold mt-4 w-full">
          <span className="w-1/5 text-right text-lg"> <FaIcon classes="fas fa-envelope" /> </span>
          <span className="w-4/5 pl-3 text-left"> {"Continue with email" |> str} </span>
        </a>
      </div>}
    </div>
  </div>
}
