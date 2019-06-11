[@bs.config {jsx: 3}];

let str = React.string;

type contentType =
  | Text
  | Image
  | Embed
  | File;

[@react.component]
let make = (~target, ~contentType, ~sortIndex, ~authenticityToken) => {
  let (sortIndex, updateSortIndex) = React.useState(() => sortIndex);
  <div
    className="content-block__container relative border border-gray-400 rounded-lg overflow-hidden">
    <div
      className="content-block__controls flex absolute right-0 top-0 bg-white rounded-bl shadow">
      <button
        title="Move up"
        className="px-3 py-2 text-gray-700 hover:text-primary-400 hover:bg-primary-100 focus:outline-none">
        <i className="fas fa-arrow-up" />
      </button>
      <button
        title="Move down"
        className="px-3 py-2 text-gray-700 hover:text-primary-400 hover:bg-primary-100 focus:outline-none">
        <i className="fas fa-arrow-down" />
      </button>
      <button
        title="Delete block"
        className="px-3 py-2 text-gray-700 hover:text-red-500 hover:bg-red-100 focus:outline-none">
        <i className="fas fa-trash-alt" />
      </button>
    </div>
    <div
      className="content-block bg-gray-200 flex justify-center items-center">
      <div className="content-block-type__image-placeholder text-center p-10">
        <i className="fas fa-image text-6xl text-gray-500" />
        <p className="text-xs text-gray-700 mt-1">
          {"You can upload PNG, JPG, GIF files" |> str}
        </p>
        <div className="flex justify-center relative mt-2">
          <input
            id="content-block-type__image-input"
            type_="file"
            className="input-file__input cursor-pointer px-4"
          />
          <label
            className="btn btn-primary flex absolute"
            htmlFor="content-block-type__image-input">
            <i className="fas fa-upload" />
            <span className="ml-2 truncate"> {"Select an image" |> str} </span>
          </label>
        </div>
      </div>
    </div>
    <div className="content-block__action-bar flex p-3 border-t">
      <div className="flex-1 content-block__action-bar-input">
        <input
          className="appearance-none block w-full h-10 bg-white text-gray-800 border border-transparent rounded py-3 px-3 focus:border-gray-400 leading-tight focus:outline-none focus:bg-white focus:border-gray"
          id="ImageCaption"
          type_="text"
          placeholder="Type caption for image (optional)"
        />
      </div>
      <div className="ml-2 text-right">
        <button className="btn btn-large btn-success">
          {"Save" |> str}
        </button>
      </div>
    </div>
  </div>;
};