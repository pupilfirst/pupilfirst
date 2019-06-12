[@bs.config {jsx: 3}];

let str = React.string;

let attachments =
  <div className="flex flex-wrap">
    <span
      className="mt-2 mr-2 flex items-center border-2 border-blue-200 bg-blue-200 rounded-lg">
      <span className="flex p-2 bg-blue-200 cursor-pointer">
        <i className="fas fa-times" />
      </span>
      <span className="bg-blue-100 rounded px-2 py-1 truncate rounded-lg">
        <span className="text-xs font-semibold text-primary-600">
          {"https://www.example.com/a-long-url" |> str}
        </span>
      </span>
    </span>
    <span
      className="mt-2 mr-2 flex items-center border-2 border-primary-200 bg-primary-200 rounded-lg">
      <span className="flex p-2 bg-primary-200 cursor-pointer">
        <i className="fas fa-times" />
      </span>
      <span className="bg-primary-100 rounded px-2 py-1 truncate rounded-lg">
        <span className="text-xs font-semibold text-primary-600">
          {"filename.pdf" |> str}
        </span>
      </span>
    </span>
  </div>;

type buttonState =
  | Attaching
  | Saving
  | Incomplete
  | Ready;

let buttonContents = buttonState => {
  let icon =
    switch (buttonState) {
    | Attaching
    | Saving => <FaIcon classes="fal fa-spinner-third fa-spin mr-2" />
    | Incomplete => React.null
    | Ready => <FaIcon classes="fas fa-cloud-upload mr-2" />
    };

  let text =
    (
      switch (buttonState) {
      | Attaching => "Attaching..."
      | Saving => "Submitting..."
      | Incomplete
      | Ready => "Submit"
      }
    )
    |> str;

  <span> icon text </span>;
};

let isButtonDisabled = buttonState =>
  switch (buttonState) {
  | Attaching
  | Saving
  | Incomplete => true
  | Ready => false
  };

[@react.component]
let make = (~authenticityToken, ~target) => {
  let (buttonState, setButtonState) = React.useState(() => Incomplete);

  <div className="bg-gray-200 pt-6 px-4 pb-2 mt-4 shadow rounded-lg">
    <h5 className="pl-1"> {"Work on your submission" |> str} </h5>
    <textarea
      className="h-40 w-full rounded-lg mt-4 p-4 border rounded-lg"
      placeholder="Describe your work, attach any links or files, and then hit submit!"
    />
    attachments
    <CourseShow__NewAttachment
      authenticityToken
      attachingCB={() => setButtonState(_ => Attaching)}
      attachFileCB={
        (id, filename) => Js.log3("Add new file attachment", id, filename)
      }
    />
    <div className="flex mt-3 justify-end">
      <button
        disabled={isButtonDisabled(buttonState)}
        className="btn btn-primary flex justify-center flex-grow md:flex-grow-0">
        {buttonContents(buttonState)}
      </button>
    </div>
  </div>;
};
