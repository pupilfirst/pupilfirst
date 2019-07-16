[@bs.config {jsx: 3}];
let resetPasswordIcon: string = [%raw
  "require('./images/continue-with-email-icon.png')"
];
let invalidTokenIcon: string = [%raw "require('./images/sign-in-icon.png')"];

open SchoolAdmin__Utils;

let str = React.string;

type views =
  | ResetPassword
  | InvalidToken;

let handleErrorCB = (setSaving, ()) => setSaving(_ => false);

let handleUpdatePasswordCB = _ => {
  let window = Webapi.Dom.window;
  "/home" |> Webapi.Dom.Window.setLocation(window);
};

let updatePassword =
    (
      authenticityToken,
      token,
      newPassword,
      confirmPassword,
      setSaving,
      setView,
    ) => {
  let setPayload = token => {
    let payload = Js.Dict.empty();
    Js.Dict.set(
      payload,
      "authenticity_token",
      authenticityToken |> Js.Json.string,
    );
    Js.Dict.set(payload, "token", token |> Js.Json.string);
    Js.Dict.set(payload, "new_password", newPassword |> Js.Json.string);
    Js.Dict.set(
      payload,
      "confirm_password",
      confirmPassword |> Js.Json.string,
    );
    payload;
  };

  switch (token) {
  | Some(token) =>
    let payload = setPayload(token);
    let url = "/users/update_password";
    setSaving(_ => true);
    Api.create(
      url,
      payload,
      handleUpdatePasswordCB,
      handleErrorCB(setSaving),
    );
  | None => setView(_ => InvalidToken)
  };
};

let renderIcon = view => {
  let icon =
    switch (view) {
    | ResetPassword => resetPasswordIcon
    | InvalidToken => invalidTokenIcon
    };

  <img className="mx-auto h-20 sm:h-30" src=icon />;
};

let headerText = view =>
  switch (view) {
  | ResetPassword => "Set new password"
  | InvalidToken => "User authentication failed"
  };
let validPassword = password => password != "";

let renderUpdatePassword =
    (
      authenticityToken,
      token,
      newPassword,
      setNewPassword,
      confirmPassword,
      setConfirmPassword,
      saving,
      setSaving,
      setView,
    ) => {
  let inputClasses = "appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400";
  let labelClasses = "inline-block tracking-wide text-gray-900 text-xs font-semibold";
  <div className="pt-4 pb-5 md:px-9 items-center max-w-sm mx-auto">
    <label className=labelClasses htmlFor="new-password">
      {"New Password" |> str}
    </label>
    <input
      className=inputClasses
      id="new-password"
      value=newPassword
      type_="password"
      placeholder="********"
      onChange={event => setNewPassword(ReactEvent.Form.target(event)##value)}
    />
    <label className=labelClasses htmlFor="confirm password">
      {"Confirm Password" |> str}
    </label>
    <input
      className=inputClasses
      id="confirm password"
      value=confirmPassword
      type_="password"
      placeholder="********"
      onChange={event => setConfirmPassword(ReactEvent.Form.target(event)##value)}
    />
    <button
      disabled=saving
      onClick={
        _ =>
          updatePassword(
            authenticityToken,
            token,
            newPassword,
            confirmPassword,
            setSaving,
            setView,
          )
      }
      className="btn btn-success btn-large text-center w-full mt-4">
      {"Update password" |> str}
    </button>
  </div>;
};

let renderInvalidToken = () =>
  <div className="max-w-sm mx-auto">
    <p className="text-center">
      {"The link you followed appears to be invalid" |> str}
    </p>
  </div>;

let selectView = token =>
  switch (token) {
  | Some(_) => ResetPassword
  | None => InvalidToken
  };

[@react.component]
let make = (~token, ~authenticityToken) => {
  let (view, setView) = React.useState(() => selectView(token));
  let (newPassword, setNewPassword) = React.useState(() => "");
  let (confirmPassword, setConfirmPassword) = React.useState(() => "");
  let (saving, setSaving) = React.useState(() => false);
  <div className="bg-gray-100 sm:py-10">
    <div
      className="container mx-auto max-w-lg px-4 py-6 sm:py-8 bg-white rounded-lg shadow">
      {renderIcon(view)}
      <div className="text-lg sm:text-2xl font-bold text-center mt-4">
        {headerText(view) |> str}
      </div>
      {
        switch (view) {
        | ResetPassword =>
          renderUpdatePassword(
            authenticityToken,
            token,
            newPassword,
            setNewPassword,
            confirmPassword,
            setConfirmPassword,
            saving,
            setSaving,
            setView,
          )
        | InvalidToken => renderInvalidToken()
        }
      }
    </div>
  </div>;
};
