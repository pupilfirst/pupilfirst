let str = React.string

let t = I18n.t(~scope="components.EvaluationCriteria__Index", ...)
let ts = I18n.ts

type editorAction =
  | ShowEditor(option<EvaluationCriterion.t>)
  | Hidden

type state = {
  editorAction: editorAction,
  evaluationCriteria: array<EvaluationCriterion.t>,
}

let openEditor = (event, evaluationCriterion, setState) => {
  ReactEvent.Mouse.preventDefault(event)
  setState(state => {...state, editorAction: ShowEditor(Some(evaluationCriterion))})
}

let showEvaluationCriterion = (evaluationCriterion, setState) =>
  <div
    key={EvaluationCriterion.id(evaluationCriterion)}
    className="flex items-center shadow bg-white rounded-lg mb-4">
    <div className="course-faculty__list-item flex w-full items-center">
      <button
        title={ts("edit") ++ " " ++ EvaluationCriterion.name(evaluationCriterion)}
        onClick={event => openEditor(event, evaluationCriterion, setState)}
        className="course-faculty__list-item-details flex flex-1 items-center justify-between border border-transparent cursor-pointer rounded-lg hover:bg-gray-50 hover:text-primary-500 hover:border-primary-400 focus:outline-none focus:bg-gray-50 focus:text-primary-500 focus:ring-2 focus:ring-focusColor-500">
        <div className="flex w-full text-sm justify-between">
          <span className="flex-1 font-semibold py-5 px-5 ">
            {str(EvaluationCriterion.name(evaluationCriterion))}
          </span>
          <span className="ms-2 py-5 px-5 font-medium text-gray-600 hover:text-primary-500">
            <i className="fas fa-edit text-normal" />
            <span className="ms-1"> {str(ts("edit"))} </span>
          </span>
        </div>
      </button>
    </div>
  </div>

let addOrUpdateCriterionCB = (state, setState, criterion) => {
  let updatedCriteria = Array.append(
    [criterion],
    Js.Array.filter(
      ec => EvaluationCriterion.id(ec) != EvaluationCriterion.id(criterion),
      state.evaluationCriteria,
    ),
  )
  setState(_ => {evaluationCriteria: updatedCriteria, editorAction: Hidden})
}

@react.component
let make = (~courseId, ~evaluationCriteria) => {
  let (state, setState) = React.useState(() => {
    editorAction: Hidden,
    evaluationCriteria,
  })

  <div className="bg-gray-50 h-full">
    {switch state.editorAction {
    | Hidden => React.null
    | ShowEditor(evaluationCriterion) =>
      <SchoolAdmin__EditorDrawer
        closeDrawerCB={() => setState(state => {...state, editorAction: Hidden})}>
        <EvaluationCriterionEditor__Form
          evaluationCriterion
          courseId
          addOrUpdateCriterionCB={addOrUpdateCriterionCB(state, setState)}
        />
      </SchoolAdmin__EditorDrawer>
    }}
    <div className="flex px-6 py-2 items-center justify-between">
      <button
        onClick={_ => setState(state => {...state, editorAction: ShowEditor(None)})}
        className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-primary-300 border-dashed hover:border-primary-300 focus:border-primary-300 focus:bg-gray-50 focus:text-primary-600 focus:shadow-lg p-6 rounded-lg mt-8 cursor-pointer">
        <i className="fas fa-plus-circle" />
        <h5 className="font-semibold ms-2"> {str(t("add_new_criterion"))} </h5>
      </button>
    </div>
    <div className="px-6 pb-4 mt-5 flex flex-1">
      <div className="max-w-2xl w-full mx-auto relative">
        {React.array(
          Array.map(
            ec => showEvaluationCriterion(ec, setState),
            EvaluationCriterion.sort(state.evaluationCriteria),
          ),
        )}
      </div>
    </div>
  </div>
}
