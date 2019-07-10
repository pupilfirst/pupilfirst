[@bs.config {jsx: 3}];

open SchoolAdmin__Utils;
let str = React.string;

type views =
  | FederatedSignIn
  | SignInWithPassword
  | SignInEmailSent
  | ForgotPassword;

type omniauthProvider =
  | Google
  | Facebook
  | Github
  | Developer;

let handleErrorCB = (setSaving, ()) => setSaving(_ => false);
let handleSignInWithPasswordCB = _ => {
  let window = Webapi.Dom.window;
  "/home" |> Webapi.Dom.Window.setLocation(window);
};
let handleSignInWithEmailCB = (setView, _) => setView(_ => SignInEmailSent);

let signInWithPassword = (authenticityToken, email, password, setSaving) => {
  let setPayload = () => {
    let payload = Js.Dict.empty();
    Js.Dict.set(
      payload,
      "authenticity_token",
      authenticityToken |> Js.Json.string,
    );

    Js.Dict.set(payload, "email", email |> Js.Json.string);
    Js.Dict.set(payload, "shared_device", "true" |> Js.Json.string);
    Js.Dict.set(payload, "password", password |> Js.Json.string);
    payload;
  };
  let payload = setPayload();
  let url = "/users/sign_in";
  setSaving(_ => true);
  Api.create(
    url,
    payload,
    handleSignInWithPasswordCB,
    handleErrorCB(setSaving),
  );
};

let sendSignInEmail = (authenticityToken, email, setView, setSaving) => {
  let setPayload = () => {
    let payload = Js.Dict.empty();
    Js.Dict.set(
      payload,
      "authenticity_token",
      authenticityToken |> Js.Json.string,
    );

    Js.Dict.set(payload, "email", email |> Js.Json.string);
    Js.Dict.set(payload, "referer", "" |> Js.Json.string);
    Js.Dict.set(payload, "shared_device", "0" |> Js.Json.string);
    Js.Dict.set(payload, "username", "" |> Js.Json.string);
    payload;
  };

  let payload = setPayload();
  let url = "/users/send_login_email";
  Api.create(
    url,
    payload,
    handleSignInWithEmailCB(setView),
    handleErrorCB(setSaving),
  );
};
let renderIcon = iconUrl =>
  switch (iconUrl) {
  | Some(url) => <img className="mx-auto" src=url />
  | None => React.null
  };

let federatedLoginUrl = (oauthHost, fqdn, provider) =>
  "//"
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

let renderFederatedlogin = (fqdn, oauthHost) =>
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
  </div>;

let validPassword = password => password != "";

let renderSignInWithEmail =
    (
      email,
      setEmail,
      password,
      setPassword,
      authenticityToken,
      setView,
      saving,
      setSaving,
    ) =>
  <div>
    <label
      className="inline-block tracking-wide text-xs font-semibold mb-2"
      htmlFor="email">
      {"Enter your Email" |> str}
    </label>
    <input
      className="appearance-none block w-full bg-white text-lg font-semibold text-gray-900 border-b border-gray-400 pb-2 mb-4 leading-tight hover:border-gray-500 focus:outline-none focus:bg-white focus:border-gray-500"
      id="email"
      value=email
      type_="text"
      onChange={event => setEmail(ReactEvent.Form.target(event)##value)}
      placeholder="john@example.com"
    />
    <label
      className="inline-block tracking-wide text-xs font-semibold mb-2"
      htmlFor="password">
      {"Enter your password" |> str}
    </label>
    <input
      className="appearance-none block w-full bg-white text-lg font-semibold text-gray-900 border-b border-gray-400 pb-2 mb-4 leading-tight hover:border-gray-500 focus:outline-none focus:bg-white focus:border-gray-500"
      id="password"
      value=password
      type_="password"
      onChange={event => setPassword(ReactEvent.Form.target(event)##value)}
      placeholder="********"
    />
    <div className="text-center">
      {
        validPassword(password) ?
          <button
            disabled=saving
            onClick={
              _ =>
                signInWithPassword(
                  authenticityToken,
                  email,
                  password,
                  setSaving,
                )
            }
            className="btn btn-primary btn-large">
            {"Sign in with password" |> str}
          </button> :
          <button
            disabled=saving
            onClick={
              _ =>
                sendSignInEmail(authenticityToken, email, setView, setSaving)
            }
            className="btn btn-primary btn-large">
            {"Email me a link to sign in" |> str}
          </button>
      }
    </div>
    <div
      onClick={_ => setView(_ => ForgotPassword)}
      className="text-blue-600 text-center font-semibold hover:text-blue-700 mt-4">
      {"Fotgot Password" |> str}
    </div>
  </div>;

let renderSignInEmailSent = () =>
  <div className="text-center">
    <div className="text-4xl font-semibold mt-4">
      {"Sign-in link sent!" |> str}
    </div>
    <div className="text-sm font-normal mt-4">
      {
        "An email with a Sign-in link has been sent to your address. Please visit your inbox and follow the link to sign-in and continue."
        |> str
      }
    </div>
  </div>;

let renderForgotPassword = (email, setEmail) =>
  <div className="text-center">
    <div className="text-4xl font-semibold mt-4">
      {"Forgot Your Password?" |> str}
    </div>
    <div className="text-sm font-normal mt-4">
      {"To reset your password, please enter your email id. " |> str}
    </div>
    <label
      className="inline-block tracking-wide text-xs font-semibold mb-2"
      htmlFor="email">
      {"Enter your Email" |> str}
    </label>
    <input
      className="appearance-none block w-full bg-white text-lg font-semibold text-gray-900 border-b border-gray-400 pb-2 mb-4 leading-tight hover:border-gray-500 focus:outline-none focus:bg-white focus:border-gray-500"
      id="email"
      value=email
      type_="text"
      onChange={event => setEmail(ReactEvent.Form.target(event)##value)}
      placeholder="john@example.com"
    />
  </div>;

[@react.component]
let make = (~schoolName, ~iconUrl, ~authenticityToken, ~fqdn, ~oauthHost) => {
  let (view, setView) = React.useState(() => FederatedSignIn);
  let (email, setEmail) = React.useState(() => "");
  let (password, setPassword) = React.useState(() => "");
  let (saving, setSaving) = React.useState(() => false);
  Js.log(email);
  <div className="bg-gray-100 py-10 px-2">
    <div
      className="container mx-auto max-w-lg px-4 py-10 bg-white rounded-lg shadow-xl">
      {renderIcon(iconUrl)}
      <div className="text-2xl font-light text-center mt-4">
        {"Sign in to " ++ schoolName |> str}
      </div>
      {
        switch (view) {
        | FederatedSignIn => renderFederatedlogin(fqdn, oauthHost)
        | SignInWithPassword =>
          renderSignInWithEmail(
            email,
            setEmail,
            password,
            setPassword,
            authenticityToken,
            setView,
            saving,
            setSaving,
          )
        | SignInEmailSent => renderSignInEmailSent()
        | ForgotPassword => renderForgotPassword(email, setEmail)
        }
      }
      {
        switch (view) {
        | FederatedSignIn =>
          <div
            onClick=(_ => setView(_ => SignInWithPassword))
            className="text-blue-600 text-center font-semibold hover:text-blue-700">
            {"Sign in with email" |> str}
          </div>
        | SignInWithPassword
        | ForgotPassword =>
          <div
            onClick=(_ => setView(_ => FederatedSignIn))
            className="text-blue-600 text-center font-semibold hover:text-blue-700 mt-4">
            {"Sign in with Google, Facebook, or Github" |> str}
          </div>

        | SignInEmailSent => React.null
        }
      }
    </div>
  </div>;
};
