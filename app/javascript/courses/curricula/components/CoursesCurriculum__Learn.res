open CoursesCurriculum__Types

let t = I18n.t(~scope="components.CoursesCurriculum__Learn")

@react.component
let make = (~targetDetails, ~author, ~courseId, ~targetId) => {
  <div id="learn-component">
    {ReactUtils.nullUnless(
      <a
        className="btn btn-primary-ghost btn-small"
        href={"/school/courses/" ++ courseId ++ "/targets/" ++ targetId ++ "/content"}>
        <i className="fas fa-pencil-alt" />
        <span className="ml-2"> {t("edit_target_button")->React.string} </span>
      </a>,
      author,
    )}
    <TargetContentView
      contentBlocks={TargetDetails.contentBlocks(targetDetails)->ContentBlock.sort}
    />
  </div>
}
