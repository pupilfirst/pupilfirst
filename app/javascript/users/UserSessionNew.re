[@bs.config {jsx: 3}];

let str = React.string;

type omniauthProvider =
  | Google
  | Facebook
  | Github
  | Developer;
let renderLogo = (iconUrl, schoolName) =>
  switch (iconUrl) {
  | Some(url) => <img className="mx-auto" src=url />
  | None => React.null
  };

let federatedLoginUrl = (oauthHost, fqdn, provider) =>
  "https://"
  ++ oauthHost
  ++ "/oauth/"
  ++ (
    switch (provider) {
    | Google => "google"
    | Facebook => "facebook"
    | Github => "github"
    | Developer => "developer"
    }
  )
  ++ (
    switch (fqdn) {
    | Some(host) => "?fqdn=" ++ host
    | None => ""
    }
  );

let buttonText = provider =>
  "Continue "
  ++ (
    switch (provider) {
    | Google => "with Google"
    | Facebook => "with Facebook"
    | Github => "with Github"
    | Developer => "as Developer"
    }
  );

let buttonClasses = provider =>
  "py-4 border rounded-full cursor-pointer mt-2 w-full text-center "
  ++ (
    switch (provider) {
    | Facebook => "bg-blue-700 hover:bg-blue-800 text-white"
    | Github => "bg-gray-900 hover:bg-black text-white"
    | Google => "hover:bg-red-600 hover:text-white"
    | Developer => "hover:bg-gray-200"
    }
  );

let iconClasses = provider =>
  switch (provider) {
  | Google => "fab fa-google"
  | Facebook => "fab fa-facebook-f"
  | Github => "fab fa-github"
  | Developer => "fas fa-code"
  };

let renderFederatedlogin = (fqdn, oauthHost, setUseFederatedLogin) =>
  [|
    <div className="flex flex-col p-4 items-center max-w-sm mx-auto">
      {
        [|Developer, Google, Facebook, Github|]
        |> Array.map(provider =>
             <a
               className={buttonClasses(provider)}
               href={federatedLoginUrl(oauthHost, fqdn, provider)}>
               <i className={iconClasses(provider)} />
               <span className="pl-2"> {buttonText(provider) |> str} </span>
             </a>
           )
        |> React.array
      }
    </div>,
    <div
      onClick={_ => setUseFederatedLogin(_ => false)}
      className="text-blue-600 text-center font-semibold hover:text-blue-700">
      {"Sign in with email" |> str}
    </div>,
  |]
  |> React.array;

let validPassword = password => password != "";

let renderSignInWithEmail = (email, setEmail, password, setPassword) =>
  <div>
    <label
      className="inline-block tracking-wide text-xs font-semibold mb-2"
      htmlFor="email">
      {"Email" |> str}
    </label>
    <input
      className="appearance-none block w-full bg-white text-2xl font-semibold text-gray-900 border-b border-gray-400 pb-2 mb-4 leading-tight hover:border-gray-500 focus:outline-none focus:bg-white focus:border-gray-500"
      id="email"
      type_="text"
      onChange={event => setEmail(ReactEvent.Form.target(event)##value)}
      placeholder="Type your email here"
    />
    <label
      className="inline-block tracking-wide text-xs font-semibold mb-2"
      htmlFor="password">
      {"Password" |> str}
    </label>
    <input
      className="appearance-none block w-full bg-white text-2xl font-semibold text-gray-900 border-b border-gray-400 pb-2 mb-4 leading-tight hover:border-gray-500 focus:outline-none focus:bg-white focus:border-gray-500"
      id="password"
      type_="password"
      onChange={event => setPassword(ReactEvent.Form.target(event)##value)}
      placeholder="Type your password here"
    />
    <div className="text-center">
      {
        validPassword(password) ?
          <button className="btn btn-primary btn-large">
            {"Email me a link to sign in" |> str}
          </button> :
          <button className="btn btn-primary btn-large">
            {"Sign in with password" |> str}
          </button>
      }
    </div>
  </div>;

[@react.component]
let make = (~schoolName, ~iconUrl, ~authenticityToken, ~fqdn, ~oauthHost) => {
  let (useFederatedLogin, setUseFederatedLogin) = React.useState(() => true);
  let (email, setEmail) = React.useState(() => "");
  let (password, setPassword) = React.useState(() => "");
  <div className="bg-gray-100 py-4">
    <div
      className="container mx-auto max-w-lg px-4 py-10 bg-white rounded-lg shadow-xl">
      {renderLogo(iconUrl, schoolName)}
      <div className="text-2xl font-light text-center mt-4">
        {"Sign in to " ++ schoolName |> str}
      </div>
      {
        useFederatedLogin ?
          renderFederatedlogin(fqdn, oauthHost, setUseFederatedLogin) :
          renderSignInWithEmail(email, setEmail, password, setPassword)
      }
    </div>
  </div>;
};
