[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesCurriculum__LevelSelector.css")|}];

open CoursesCurriculum__Types;

let str = React.string;

let levelSelectorClasses = isSelected => {
  let defaultClasses = "w-1/2 px-4 py-2 focus:outline-none text-sm font-semibold ";
  defaultClasses
  ++ (
    isSelected
      ? "course-level-tab__selected bg-primary-100 text-primary-500 hover:bg-primary-100 hover:text-primary-500"
      : ""
  );
};

let levelName = level =>
  "L"
  ++ (level |> Level.number |> string_of_int)
  ++ ": "
  ++ (level |> Level.name);

let numberedLevelSelector = (selectedLevel, setShowLevelZero) => {
  let defaultClasses = "rounded-l-lg font-semibold focus:outline-none cursor-pointer ";

  let additionalClasses =
    switch (setShowLevelZero) {
    | Some(_) => "w-1/2 bg-white px-4 py-2 hover:bg-gray-100 hover:text-primary-500 truncate leading-loose text-sm"
    | None => "w-full rounded-lg bg-primary-100 border-t border-b px-2 h-10 flex items-center justify-between"
    };

  <button
    onClick={_ =>
      Belt.Option.mapWithDefault(setShowLevelZero, (), f => f(false))
    }
    className={defaultClasses ++ additionalClasses}>
    <span className="flex-grow text-center truncate w-0">
      {selectedLevel |> levelName |> str}
    </span>
    {setShowLevelZero == None
       ? <FaIcon classes="fas fa-caret-down ml-1" /> : React.null}
  </button>;
};

let selectableLevels = (orderedLevels, teamLevel, setSelectedLevelId) => {
  let teamLevelNumber = teamLevel |> Level.number;
  orderedLevels
  |> List.map(level => {
       let levelNumber = level |> Level.number;

       let icon =
         if (levelNumber < teamLevelNumber) {
           "fas fa-check text-green-500";
         } else if (levelNumber == teamLevelNumber) {
           "fas fa-map-marker-alt text-blue-400";
         } else if (level |> Level.isUnlocked) {
           "inline-block";
         } else {
           "fas fa-lock text-gray-600";
         };

       <button
         className="focus:outline-none p-2 w-full text-left"
         key={level |> Level.id}
         onClick={_ => setSelectedLevelId(level |> Level.id)}>
         <span className="mr-2"> <FaIcon classes={"fa-fw " ++ icon} /> </span>
         {levelName(level) |> str}
       </button>;
     })
  |> Array.of_list;
};

[@react.component]
let make =
    (
      ~levels,
      ~teamLevel,
      ~selectedLevel,
      ~setSelectedLevelId,
      ~showLevelZero,
      ~setShowLevelZero,
      ~levelZero,
    ) => {
  let orderedLevels =
    levels |> List.filter(l => l |> Level.number != 0) |> Level.sort;

  <div className="px-3 md:px-0">
    <div
      className="flex justify-center max-w-sm md:max-w-xl mx-auto mt-4 rounded-lg bg-primary-100 border border-gray-400 h-11">
      {showLevelZero
         ? numberedLevelSelector(selectedLevel, Some(setShowLevelZero))
         : <Dropdown
             selected={numberedLevelSelector(selectedLevel, None)}
             contents={selectableLevels(
               orderedLevels,
               teamLevel,
               setSelectedLevelId,
             )}
             className="flex-grow"
           />}
      {switch (levelZero) {
       | Some(level) =>
         <button
           className={
             "border-l rounded-r-lg bg-white border-gray-400 font-semibold truncate hover:bg-gray-100 hover:text-primary-500 "
             ++ levelSelectorClasses(showLevelZero)
           }
           onClick={_e => setShowLevelZero(true)}>
           {level |> Level.name |> str}
         </button>
       | None => React.null
       }}
    </div>
  </div>;
};
