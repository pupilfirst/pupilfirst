let str = ReasonReact.string;

type kind =
  | PrivacyPolicy
  | TermsOfUse;

type action =
  | UpdateKind(kind);

type state = {kind};

let component =
  ReasonReact.reducerComponent("SchoolCustomize__AgreementsEditor");

let make = (~kind, ~customizations, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {kind: kind},
  reducer: (action, state) =>
    switch (action) {
    | UpdateKind(kind) => ReasonReact.Update({kind: kind})
    },
  render: _self => "somethin" |> str,
};