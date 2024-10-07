let str = React.string

let t = I18n.t(~scope="components.School__SelectBox", ...)
let ts = I18n.ts

type key = string
type value = string
type selected = bool
type item = (key, value, selected)

let convertOldItems = items =>
  List.map(((key, value, selected)) => (string_of_int(key), value, selected), items)

let convertOldCallback = (cb, key, value, selected) => cb(int_of_string(key), value, selected)

@react.component
let make = (
  ~items: list<item>,
  ~selectCB: (key, value, selected) => unit,
  ~noSelectionHeading=t("none_selected"),
  ~noSelectionDescription=t("select_from_list"),
  ~emptyListDescription=t("no_items_select"),
) => {
  let (searchString, setSearchString) = React.useState(() => "")
  let selectedList = List.filter(((_, _, selected)) => selected == true, items)
  let nonSelectedList = List.filter(((_, _, selected)) => selected == false, items)
  let filteredList = switch nonSelectedList {
  | list{} => list{}
  | someList =>
    List.filter(
      ((_, value, _)) =>
        Js.String.includes(String.lowercase_ascii(searchString), String.lowercase_ascii(value)),
      someList,
    )
  }

  <div className="p-6 border rounded bg-gray-50">
    {List.length(selectedList) > 0
      ? React.array(Array.of_list(List.map(((key, value, _)) =>
              <div
                key
                className="select-list__item-selected flex items-center justify-between bg-white font-semibold text-xs border rounded mb-2">
                <div className="p-3 flex-1"> {str(value)} </div>
                <button
                  className="flex p-3 text-gray-800 hover:bg-gray-50 hover:text-gray-900 focus:outline-none"
                  title={t("remove")}
                  onClick={_event => {
                    ReactEvent.Mouse.preventDefault(_event)
                    setSearchString(_ => "")
                    selectCB(key, value, false)
                  }}>
                  <i className="fas fa-trash-alt text-base" />
                </button>
              </div>
            , List.rev(selectedList))))
      : <div
          className="flex flex-col items-center justify-center bg-gray-50 text-gray-800 rounded px-3 pt-3 ">
          <i className="fas fa-inbox text-3xl" />
          <h5 className="mt-1 font-semibold"> {str(noSelectionHeading)} </h5>
          <span className="text-xs">
            {str(ListUtils.isEmpty(items) ? emptyListDescription : noSelectionDescription)}
          </span>
        </div>}
    {List.length(nonSelectedList) > 0
      ? <div className="flex relative pt-4">
          <div className="select-list__group text-sm bg-white rounded shadow pb-2 w-full">
            {List.length(nonSelectedList) > 3
              ? <div className="px-3 pt-3 pb-2">
                  <input
                    className="appearance-none bg-transparent border-b w-full text-gray-600 pb-3 px-2 ps-0 leading-normal focus:outline-none"
                    type_="text"
                    placeholder={t("type_search")}
                    onChange={event => setSearchString(ReactEvent.Form.target(event)["value"])}
                  />
                </div>
              : React.null}
            <div className={List.length(nonSelectedList) > 3 ? "h-28 overflow-y-scroll" : ""}>
              {React.array(Array.of_list(List.map(((key, value, _)) =>
                    <div
                      key
                      onClick={_event => {
                        ReactEvent.Mouse.preventDefault(_event)
                        setSearchString(_ => "")
                        selectCB(key, value, true)
                      }}
                      title={t("select") ++ " " ++ value}
                      className="px-3 py-2 font-semibold hover:bg-primary-100 hover:text-primary-500 cursor-pointer">
                      {str(value)}
                    </div>
                  , filteredList)))}
            </div>
          </div>
        </div>
      : React.null}
  </div>
}
