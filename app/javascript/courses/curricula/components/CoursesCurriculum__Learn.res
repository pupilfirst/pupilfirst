open CoursesCurriculum__Types

@react.component
let make = (~targetDetails, ~author, ~courseId, ~targetId) => {
  <div id="learn-component">
    {ReactUtils.nullUnless(
      <a
        className="btn btn-primary-ghost btn-small"
        href={"/school/courses/" ++ courseId ++ "/targets/" ++ targetId ++ "/content"}>
        <i className="fas fa-pencil-alt" />
        <span className="ml-2"> {React.string("Edit Content")} </span>
      </a>,
      author,
    )}
    <TargetContentView
      contentBlocks={TargetDetails.contentBlocks(targetDetails)->ContentBlock.sort}
    />
  </div>
}
