%%raw(`import "./EvaluationCriterionEditor__Form.css"`)

let str = React.string

let t = I18n.t(~scope="components.EvaluationCriterionEditor__Form")
let ts = I18n.ts

type state = {
  name: string,
  maxGrade: int,
  gradesAndLabels: array<GradeLabel.t>,
  saving: bool,
  dirty: bool,
}

module CreateEvaluationCriterionQuery = %graphql(`
   mutation CreateEvaluationCriterionMutation($name: String!, $courseId: ID!, $maxGrade: Int!, $gradesAndLabels: [GradeAndLabelInput!]!) {
     createEvaluationCriterion(courseId: $courseId, name: $name, maxGrade: $maxGrade, gradesAndLabels: $gradesAndLabels ) {
       evaluationCriterion {
        id
        name
        maxGrade
        gradeLabels {
          grade
          label
        }
       }
     }
   }
   `)

module UpdateEvaluationCriterionQuery = %graphql(`
   mutation UpdateEvaluationCriterionMutation($id: ID!, $name: String!, $gradesAndLabels: [GradeAndLabelInput!]!) {
    updateEvaluationCriterion(id: $id, name: $name, gradesAndLabels: $gradesAndLabels){
       evaluationCriterion {
        id
        name
        maxGrade
        gradeLabels {
          grade
          label
        }
       }
      }
   }
   `)

let formClasses = value =>
  value ? "drawer-right-form w-full opacity-50" : "drawer-right-form w-full"

let possibleGradeValues: list<int> = list{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

let gradeBarBulletClasses = (selected, passed, empty) => {
  let classes = selected ? " grade-bar__pointer--selected" : " "
  if empty {
    classes ++ " grade-bar__pointer--pulse"
  } else if passed {
    classes ++ " grade-bar__pointer--passed"
  } else {
    classes ++ " grade-bar__pointer--failed"
  }
}

let updateMaxGrade = (value, setState) => setState(state => {...state, maxGrade: value})

let updateGradeLabel = (value, gradeAndLabel, state, setState) => {
  let updatedGradeAndLabel = GradeLabel.update(value, gradeAndLabel)
  let gradesAndLabels =
    state.gradesAndLabels |> Array.map(gl =>
      gl |> GradeLabel.grade == (updatedGradeAndLabel |> GradeLabel.grade)
        ? updatedGradeAndLabel
        : gl
    )
  setState(state => {...state, gradesAndLabels, dirty: true})
}

let updateEvaluationCriterion = (state, setState, addOrUpdateCriterionCB, criterion) => {
  setState(state => {...state, saving: true})

  let gradesAndLabels =
    state.gradesAndLabels
    ->Js.Array2.filter(gradesAndLabel => gradesAndLabel |> GradeLabel.grade <= state.maxGrade)
    ->Js.Array2.map(gradesAndLabel =>
      UpdateEvaluationCriterionQuery.makeInputObjectGradeAndLabelInput(
        ~grade=GradeLabel.grade(gradesAndLabel),
        ~label=GradeLabel.label(gradesAndLabel),
        (),
      )
    )

  UpdateEvaluationCriterionQuery.make({
    id: criterion |> EvaluationCriterion.id,
    name: state.name,
    gradesAndLabels,
  })
  |> Js.Promise.then_(result => {
    switch result["updateEvaluationCriterion"]["evaluationCriterion"] {
    | Some(criterion) =>
      let updatedCriterion = EvaluationCriterion.makeFromJs(criterion)
      addOrUpdateCriterionCB(updatedCriterion)
      setState(state => {...state, saving: false})
    | None => setState(state => {...state, saving: false})
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let createEvaluationCriterion = (state, setState, addOrUpdateCriterionCB, courseId) => {
  setState(state => {...state, saving: true})

  let gradesAndLabels =
    state.gradesAndLabels
    ->Js.Array2.filter(gradesAndLabel => gradesAndLabel |> GradeLabel.grade <= state.maxGrade)
    ->Js.Array2.map(gradesAndLabel =>
      CreateEvaluationCriterionQuery.makeInputObjectGradeAndLabelInput(
        ~grade=GradeLabel.grade(gradesAndLabel),
        ~label=GradeLabel.label(gradesAndLabel),
        (),
      )
    )

  let variables = CreateEvaluationCriterionQuery.makeVariables(
    ~name=state.name,
    ~maxGrade=state.maxGrade,
    ~courseId,
    ~gradesAndLabels,
    (),
  )

  CreateEvaluationCriterionQuery.make(variables)
  |> Js.Promise.then_(result => {
    switch result["createEvaluationCriterion"]["evaluationCriterion"] {
    | Some(criterion) =>
      let newCriterion = EvaluationCriterion.makeFromJs(criterion)
      addOrUpdateCriterionCB(newCriterion)
      setState(state => {...state, saving: false})
    | None => setState(state => {...state, saving: false})
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let updateName = (setState, value) => setState(state => {...state, dirty: true, name: value})

let saveDisabled = state => {
  let hasValidName = state.name |> String.trim |> String.length > 0
  !state.dirty || (state.saving || !hasValidName)
}

let labels = (state, setState) =>
  state.gradesAndLabels
  |> Js.Array.filter(gnl => gnl |> GradeLabel.grade <= state.maxGrade)
  |> Array.map(gradeAndLabel => {
    let grade = gradeAndLabel |> GradeLabel.grade

    <div key={grade |> string_of_int} className="flex flex-wrap mt-2">
      <div className="flex-1">
        <input
          id={"grade-label-for-" ++ (grade |> string_of_int)}
          className=" appearance-none border rounded w-full p-3 text-gray-600 leading-tight focus:outline-none focus:ring"
          type_="text"
          maxLength=40
          value={gradeAndLabel |> GradeLabel.label}
          onChange={event =>
            updateGradeLabel(
              ReactEvent.Form.target(event)["value"],
              gradeAndLabel,
              state,
              setState,
            )}
          placeholder={t("label_grade_placeholder") ++
          " " ++
          (gradeAndLabel |> GradeLabel.grade |> string_of_int)}
        />
      </div>
    </div>
  })

@react.component
let make = (~evaluationCriterion, ~courseId, ~addOrUpdateCriterionCB) => {
  let (state, setState) = React.useState(() =>
    switch evaluationCriterion {
    | None => {
        name: "",
        maxGrade: 5,
        gradesAndLabels: possibleGradeValues |> List.map(i => GradeLabel.empty(i)) |> Array.of_list,
        saving: false,
        dirty: false,
      }
    | Some(ec) => {
        name: ec |> EvaluationCriterion.name,
        maxGrade: ec |> EvaluationCriterion.maxGrade,
        gradesAndLabels: ec |> EvaluationCriterion.gradesAndLabels,
        saving: false,
        dirty: false,
      }
    }
  )
  <div className="mx-auto bg-white">
    <div className="max-w-2xl p-6 mx-auto">
      <h5 className="uppercase text-center border-b border-gray-300 pb-2">
        {switch evaluationCriterion {
        | None => t("add_criterion")
        | Some(ec) => ec |> EvaluationCriterion.name
        } |> str}
      </h5>
      <DisablingCover
        disabled=state.saving
        message={switch evaluationCriterion {
        | Some(_ec) => ts("updating") ++ "..."
        | None => ts("saving")
        }}>
        <div key="evaluation-criterion-editor" className="mt-3">
          <div className="mt-5">
            <label className="inline-block tracking-wide text-xs font-semibold " htmlFor="name">
              {ts("name") |> str}
            </label>
            <input
              autoFocus=true
              className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
              id="name"
              onChange={event => updateName(setState, ReactEvent.Form.target(event)["value"])}
              type_="text"
              placeholder={t("name_placeholder")}
              maxLength=50
              value=state.name
            />
            <School__InputGroupError
              message={t("name_error")}
              active={state.dirty && state.name |> String.trim |> String.length < 1}
            />
          </div>
        </div>
        <div className="mx-auto">
          <div className="max-w-2xl pt-6 mx-auto">
            <div className="mb-4">
              <span
                className="inline-block tracking-wide text-sm font-semibold me-2"
                htmlFor="max_grades">
                {t("max_grade") |> str}
              </span>
              {switch evaluationCriterion {
              | Some(_) =>
                <span
                  className="cursor-not-allowed inline-block bg-white border-b-2 text-2xl font-semibold text-center border-blue px-3 py-2 leading-tight rounded-none focus:outline-none">
                  {state.maxGrade |> string_of_int |> str}
                </span>
              | None =>
                <select
                  onChange={event =>
                    updateMaxGrade(
                      ReactEvent.Form.target(event)["value"] |> int_of_string,
                      setState,
                    )}
                  id="max_grade"
                  value={state.maxGrade |> string_of_int}
                  className="cursor-pointer inline-block appearance-none bg-white border-b-2 text-2xl font-semibold text-center border-blue hover:border-blue-500 px-3 py-2 leading-tight rounded-none focus:outline-none focus:border-focusColor-500">
                  {possibleGradeValues
                  |> List.map(possibleGradeValue =>
                    <option
                      key={possibleGradeValue |> string_of_int}
                      value={possibleGradeValue |> string_of_int}>
                      {possibleGradeValue |> string_of_int |> str}
                    </option>
                  )
                  |> Array.of_list
                  |> React.array}
                </select>
              }}
            </div>
            <div className="flex justify-between">
              <div className="flex items-center">
                <label className="block tracking-wide text-xs font-semibold" htmlFor="grades">
                  {t("grade_labels.label") |> str}
                </label>
                <HelpIcon className="ms-2" link={t("grade_labels.help_url")}>
                  {t("grade_labels.help") |> str}
                </HelpIcon>
              </div>
            </div>
            <div ariaLabel="label-editor"> {labels(state, setState) |> React.array} </div>
            <div className="mt-3 mb-3 text-xs">
              <span className="leading-normal">
                <strong> {t("important") ++ ":" |> str} </strong>
                {" " ++ t("important_details") |> str}
              </span>
            </div>
            <div className="flex">
              {switch evaluationCriterion {
              | Some(criterion) =>
                <button
                  disabled={saveDisabled(state)}
                  onClick={_ =>
                    updateEvaluationCriterion(state, setState, addOrUpdateCriterionCB, criterion)}
                  className="w-full btn btn-large btn-primary mt-3">
                  {t("update_criterion") |> str}
                </button>

              | None =>
                <button
                  disabled={saveDisabled(state)}
                  onClick={_ =>
                    createEvaluationCriterion(state, setState, addOrUpdateCriterionCB, courseId)}
                  className="w-full btn btn-large btn-primary mt-3">
                  {t("create_criterion") |> str}
                </button>
              }}
            </div>
          </div>
        </div>
      </DisablingCover>
    </div>
  </div>
}
