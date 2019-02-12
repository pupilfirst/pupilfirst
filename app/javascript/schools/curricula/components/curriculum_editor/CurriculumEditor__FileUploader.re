open CurriculumEditor__Types;

exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent("CurriculumEditor__FileUploader");

let handleResponseJSON = json => {
  let id =
    json |> Json.Decode.(field("id", nullable(int))) |> Js.Null.toOption;
  let error =
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption;
  switch (error) {
  | Some(err) => Notification.error("Something went wrong!", err)
  | None => Notification.success("Success", "Target Created")
  };
  Js.log(id);
};

let createFile = formData =>
  Js.Promise.(
    Fetch.fetchWithInit(
      "/school/resources/",
      Fetch.RequestInit.make(
        ~method_=Post,
        ~body=Fetch.BodyInit.makeWithFormData(formData),
        ~credentials=Fetch.SameOrigin,
        (),
      ),
    )
    |> then_(response =>
         if (Fetch.Response.ok(response)
             || Fetch.Response.status(response) == 422) {
           response |> Fetch.Response.json;
         } else {
           Js.Promise.reject(
             UnexpectedResponse(response |> Fetch.Response.status),
           );
         }
       )
    |> then_(json => handleResponseJSON(json) |> resolve)
    |> catch(error =>
         (
           switch (error |> handleApiError) {
           | Some(code) =>
             Notification.error(code |> string_of_int, "Please try again")
           | None =>
             Notification.error("Something went wrong!", "Please try again")
           }
         )
         |> resolve
       )
    |> ignore
  );

let submitForm = event => {
  ReactEvent.Form.preventDefault(event);
  let element = ReactDOMRe._getElementById("file-new-bodhish-test-hello");
  switch (element) {
  | Some(element) => createFile(FormData.create(element))
  | None => ()
  };
};

let make = _children => {
  ...component,
  render: _self =>
    <form
      id="file-new-bodhish-test-hello" onSubmit={event => submitForm(event)}>
      <div
        className="resources-upload-tab__body p-5 border-l border-r border-b rounded rounded-tl-none rounded-tr-none">
        <input
          name="resource[title]"
          className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
          id="title"
          type_="text"
          placeholder="Type target title here"
        />
        <input
          name="resource[description]"
          className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
          id="description"
          type_="text"
          placeholder="Type target description here"
        />
        <input name="resource[file]" type_="file" id="file" multiple=true />
        /* <label className="flex items-center text-sm" htmlFor="file">
             <svg
               xmlns="http://www.w3.org/2000/svg"
               width="20"
               height="17"
               fill="#9FB0CC"
               viewBox="0 0 20 17">
               <path
                 d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"
               />
             </svg>
             <span className="ml-2"> {"Choose a file &hellip;" |> str} </span>
           </label> */
        <button
          className="w-1/2 bg-white hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none">
          {"Yes" |> str}
        </button>
      </div>
    </form>,
};