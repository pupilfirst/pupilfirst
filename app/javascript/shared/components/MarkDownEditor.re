[@bs.config {jsx: 3}];

type element;
[@bs.scope "document"] [@bs.val]
external getElementById: string => element = "";
[@bs.get] external selectionStart: element => int = "";
[@bs.get] external selectionEnd: element => int = "";
[@bs.get] external value: element => string = "";

type action =
  | Bold
  | Italics
  | Code;

let str = React.string;

[@react.component]
let make = (~placeholderText, ~updateDescriptionCB) => {
  let (description, setDescription) = React.useState(() => "");
  let (showPreview, setShowPreview) = React.useState(() => false);

  let handleClick = (action, event) => {
    event |> ReactEvent.Mouse.preventDefault;

    let actionString =
      switch (action) {
      | Bold => "**"
      | Italics => "*"
      | Code => "`"
      };
    let textAreaElement = getElementById("mytextarea");
    let start = selectionStart(textAreaElement);
    let finish = selectionEnd(textAreaElement);
    let inputText = value(textAreaElement);
    let sel = Js.String.substring(~from=start, ~to_=finish, inputText);

    let newText =
      if (start != finish) {
        Js.String.substring(~from=0, ~to_=start, inputText)
        ++ actionString
        ++ sel
        ++ actionString
        ++ Js.String.substring(
             ~from=finish,
             ~to_=inputText |> Js.String.length,
             inputText,
           );
      } else {
        inputText
        ++ (
          switch (action) {
          | Bold => "**strong text**"
          | Italics => "*emphasized text*"
          | Code => "`enter code here`"
          }
        );
      };
    setDescription(_ => newText);
    updateDescriptionCB(newText);
  };

  <div>
    <div className="flex w-full justify-between py-2">
      {
        showPreview ?
          <div> {"Preview" |> str} </div> :
          <div className="flex w-full ">
            <button className="border p-2" onClick={handleClick(Bold)}>
              {"Bold" |> str}
            </button>
            <button className="border p-2" onClick={handleClick(Italics)}>
              {"Italics" |> str}
            </button>
            <button className="border p-2" onClick={handleClick(Code)}>
              {"Code" |> str}
            </button>
          </div>
      }
      <button
        className="border p-2"
        onClick={_ => setShowPreview(_ => !showPreview)}>
        {(showPreview ? "Edit" : "Preview") |> str}
      </button>
    </div>
    {
      showPreview ?
        <div
          className="py-4 px-6 leading-normal text-sm"
          dangerouslySetInnerHTML={"__html": description |> Markdown.parse}
        /> :
        <textarea
          id="mytextarea"
          maxLength=1000
          placeholder=placeholderText
          value=description
          onChange={
            event => setDescription(ReactEvent.Form.target(event)##value)
          }
          className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
        />
    }
  </div>;
};