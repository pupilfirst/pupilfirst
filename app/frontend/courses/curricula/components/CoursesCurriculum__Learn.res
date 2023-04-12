open CoursesCurriculum__Types

%%raw(`import "./CoursesCurriculum__Learn.css"`)
let t = I18n.t(~scope="components.CoursesCurriculum__Learn")

@react.component
let make = (~targetDetails, ~author, ~courseId, ~targetId) => {
  <div id="learn-component">
    {ReactUtils.nullUnless(
      <a
        className="btn btn-primary-ghost btn-small course-curriculum__learn-edit-content-btn"
        href={"/school/courses/" ++ courseId ++ "/targets/" ++ targetId ++ "/content"}>
        <i className="fas fa-pencil-alt" />
        <span className="ms-2"> {t("edit_target_button")->React.string} </span>
      </a>,
      author,
    )}
    <TargetContentView
      contentBlocks={TargetDetails.contentBlocks(targetDetails)->ContentBlock.sort}
    />
  </div>
}
