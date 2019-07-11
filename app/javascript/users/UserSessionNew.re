[@bs.config {jsx: 3}];
[%bs.raw {|require("./UserSessionNew.css")|}];

let federatedSignInIcon: string = [%raw "require('./images/sign-in-icon.png')"];
let signInWithPasswordIcon: string = [%raw "require('./images/continue-with-email-icon.png')"];
let signInEmailSentIcon: string = [%raw "require('./images/magic-link-sent-icon.png')"];
let forgotPasswordIcon: string = [%raw "require('./images/continue-with-email-icon.png')"];

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

let renderIcon = view =>{
  let iconUrl = switch (view) {
    | FederatedSignIn => federatedSignInIcon
    | SignInWithPassword => signInWithPasswordIcon
    | SignInEmailSent => signInEmailSentIcon
    | ForgotPassword => forgotPasswordIcon
    };
  <img className="mx-auto h-20 sm:h-30" src=iconUrl />
  };

  let headerText = (view, schoolName) => {
    switch (view) {
    | FederatedSignIn => "Sign in to " ++ schoolName
    | SignInWithPassword => "Continue with email"
    | SignInEmailSent => "Magic link is in your inbox"
    | ForgotPassword => "Reset password"
    };
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
  "flex justify-center items-center px-3 py-2 leading-snug border border-transparent rounded-lg cursor-pointer font-semibold mt-4 w-full "
  ++ (
    switch (provider) {
    | Facebook => "federated-sigin-in__facebook-btn hover:bg-blue-800 text-white"
    | Github => "federated-sigin-in__github-btn hover:bg-black text-white"
    | Google => "federated-sigin-in__google-btn hover:bg-red-600 text-white"
    | Developer => "bg-green-100 border-green-400 text-green-800 hover:bg-green-200"
    }
  );

let iconClasses = provider =>
  switch (provider) {
  | Google => "fab fa-google"
  | Facebook => "fab fa-facebook-f mr-1"
  | Github => "fab fa-github"
  | Developer => "fas fa-laptop-code"
  };

let renderFederatedlogin = (fqdn, oauthHost) =>
  <div
    className="flex flex-col pb-5 md:px-9 items-center max-w-sm mx-auto">
    {
      [|Developer, Google, Facebook, Github|]
      |> Array.map(provider =>
           <a
             className={buttonClasses(provider)}
             href={federatedLoginUrl(oauthHost, fqdn, provider)}>
             <span className="w-1/5 text-right text-lg">
               <i className={iconClasses(provider)} />
             </span>
             <span className="w-4/5 pl-3 text-left">
               {buttonText(provider) |> str}
             </span>
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
  <div className="pt-4 pb-5 md:px-9 items-center max-w-sm mx-auto">
    <div>
      <label
        className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
        htmlFor="email">
        {"Email Address" |> str}
      </label>
      <input
        className="appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
        id="email"
        value=email
        type_="text"
        onChange={event => setEmail(ReactEvent.Form.target(event)##value)}
        placeholder="john@example.com"
      />
    </div>
    <div className="mt-4">
      <label
        className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
        htmlFor="password">
        {"Password" |> str}
      </label>
      <input
        className="appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
        id="password"
        value=password
        type_="password"
        onChange={event => setPassword(ReactEvent.Form.target(event)##value)}
        placeholder="Type your password"
      />
    </div>
    <div className="flex justify-between items-center leading-snug mt-4 flex-col flex-col-reverse sm:flex-row">
      <div className="flex items-center text-gray-700 hover:text-gray-900 pt-4 sm:pt-0">
        <input className="leading-tight" id="sharedDevice" type_="checkbox"/>
        <label className="block pl-2 font-semibold leading-tight cursor-pointer text-xs select-none whitespace-no-wrap" htmlFor="sharedDevice">
          {"Are you using a shared device?" |> str}
        </label>
      </div>
      <div
        onClick={_ => setView(_ => ForgotPassword)}
        className="text-primary-400 text-center text-xs font-semibold hover:text-primary-600 cursor-pointer whitespace-no-wrap hover:underline">
        {"Fotgot Password" |> str}
      </div>
    </div>
    <div className="mt-5">
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
            className="btn btn-success btn-large text-center w-full">
            {"Sign in with password" |> str}
          </button> :
          <button
            disabled=saving
            onClick={
              _ =>
                sendSignInEmail(authenticityToken, email, setView, setSaving)
            }
            className="btn btn-primary btn-large text-center w-full">
            {"Email me a link to sign in" |> str}
          </button>
      }
    </div>
  </div>;

let renderSignInEmailSent = () =>
  <div className="max-w-sm mx-auto md:px-9 pb-4">
    <p className="mt-4 text-center">
      {
        "We just emailed a confirmation link to your email address. Click the link, and you'll be signed in."
        |> str
      }
    </p>
  </div>;

let renderForgotPassword = (email, setEmail) =>
  <div className="max-w-sm mx-auto md:px-9 pb-4">
    <div className="text-sm mt-2 text-center pb-3">
      {"Enter your email for password recovery" |> str}
    </div>
    <label
      className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
      htmlFor="email">
      {"Email" |> str}
    </label>
    <input
      className="appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
      id="email"
      value=email
      type_="text"
      onChange={event => setEmail(ReactEvent.Form.target(event)##value)}
      placeholder="john@example.com"
    />
    <button className="btn btn-primary btn-large text-center w-full mt-4">
      {"Send Email" |> str}
    </button>
  </div>;

[@react.component]
let make = (~schoolName, ~iconUrl, ~authenticityToken, ~fqdn, ~oauthHost) => {
  let (view, setView) = React.useState(() => FederatedSignIn);
  let (email, setEmail) = React.useState(() => "");
  let (password, setPassword) = React.useState(() => "");
  let (saving, setSaving) = React.useState(() => false);
  Js.log(email);
  <div className="bg-gray-100 sm:py-10">
    <div
      className="container mx-auto max-w-lg px-4 py-6 sm:py-8 bg-white rounded-lg shadow">
      {renderIcon(view)}
      <div className="text-lg sm:text-2xl font-bold text-center mt-4">
        {headerText(view, schoolName) |> str}
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
          <div className="max-w-sm mx-auto md:px-9">
            <span
              className="federated-sigin-in__seperator block relative z-10 text-center text-xs text-gray-600 font-semibold">
              <span className="bg-white px-2"> {"OR" |> str} </span>
            </span>
            <div
              onClick=(_ => setView(_ => SignInWithPassword))
              className="flex justify-center items-center px-3 py-2 leading-snug border border-gray-400 text-primary-500 hover:bg-gray-100 hover:border-primary-500 rounded-lg cursor-pointer font-semibold mt-4 w-full">
              <span className="w-1/5 text-right text-lg">
                <i className="fas fa-envelope" />
              </span>
              <span className="w-4/5 pl-3 text-left">
                {"Continue with email" |> str}
              </span>
            </div>
          </div>
        | SignInWithPassword
        | ForgotPassword =>
          <div className="max-w-sm mx-auto md:px-9">
            <div
              onClick=(_ => setView(_ => FederatedSignIn))
              className="p-3 text-primary-500 leading-snug rounded-lg underline cursor-pointer text-sm text-center font-semibold hover:bg-gray-200">
              {"Sign in with Google, Facebook, or Github" |> str}
            </div>
          </div>

        | SignInEmailSent => React.null
        }
      }
    </div>
  </div>;
};