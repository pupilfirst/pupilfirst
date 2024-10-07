%%raw(`import "./EvaluationCriterionEditor__Form.css"`)

let str = React.string

let t = I18n.t(~scope="components.EvaluationCriterionEditor__Form", ...)
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
  let gradesAndLabels = Array.map(
    gl =>
      GradeLabel.grade(gl) == GradeLabel.grade(updatedGradeAndLabel) ? updatedGradeAndLabel : gl,
    state.gradesAndLabels,
  )
  setState(state => {...state, gradesAndLabels, dirty: true})
}

let updateEvaluationCriterion = (state, setState, addOrUpdateCriterionCB, criterion) => {
  setState(state => {...state, saving: true})

  let gradesAndLabels =
    state.gradesAndLabels
    ->Js.Array2.filter(gradesAndLabel => GradeLabel.grade(gradesAndLabel) <= state.maxGrade)
    ->Js.Array2.map(gradesAndLabel =>
      UpdateEvaluationCriterionQuery.makeInputObjectGradeAndLabelInput(
        ~grade=GradeLabel.grade(gradesAndLabel),
        ~label=GradeLabel.label(gradesAndLabel),
        (),
      )
    )

  ignore(
    Js.Promise.then_(
      result => {
        switch result["updateEvaluationCriterion"]["evaluationCriterion"] {
        | Some(criterion) =>
          let updatedCriterion = EvaluationCriterion.makeFromJs(criterion)
          addOrUpdateCriterionCB(updatedCriterion)
          setState(state => {...state, saving: false})
        | None => setState(state => {...state, saving: false})
        }
        Js.Promise.resolve()
      },
      UpdateEvaluationCriterionQuery.make({
        id: EvaluationCriterion.id(criterion),
        name: state.name,
        gradesAndLabels,
      }),
    ),
  )
}

let createEvaluationCriterion = (state, setState, addOrUpdateCriterionCB, courseId) => {
  setState(state => {...state, saving: true})

  let gradesAndLabels =
    state.gradesAndLabels
    ->Js.Array2.filter(gradesAndLabel => GradeLabel.grade(gradesAndLabel) <= state.maxGrade)
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

  ignore(Js.Promise.then_(result => {
      switch result["createEvaluationCriterion"]["evaluationCriterion"] {
      | Some(criterion) =>
        let newCriterion = EvaluationCriterion.makeFromJs(criterion)
        addOrUpdateCriterionCB(newCriterion)
        setState(state => {...state, saving: false})
      | None => setState(state => {...state, saving: false})
      }
      Js.Promise.resolve()
    }, CreateEvaluationCriterionQuery.make(variables)))
}

let updateName = (setState, value) => setState(state => {...state, dirty: true, name: value})

let saveDisabled = state => {
  let hasValidName = String.length(String.trim(state.name)) > 0
  !state.dirty || (state.saving || !hasValidName)
}

let labels = (state, setState) => Array.map(gradeAndLabel => {
    let grade = GradeLabel.grade(gradeAndLabel)

    <div key={string_of_int(grade)} className="flex flex-wrap mt-2">
      <div className="flex-1">
        <input
          id={"grade-label-for-" ++ string_of_int(grade)}
          className=" appearance-none border rounded w-full p-3 text-gray-600 leading-tight focus:outline-none focus:ring"
          type_="text"
          maxLength=40
          value={GradeLabel.label(gradeAndLabel)}
          onChange={event =>
            updateGradeLabel(
              ReactEvent.Form.target(event)["value"],
              gradeAndLabel,
              state,
              setState,
            )}
          placeholder={t("label_grade_placeholder") ++
          " " ++
          string_of_int(GradeLabel.grade(gradeAndLabel))}
        />
      </div>
    </div>
  }, Js.Array.filter(gnl => GradeLabel.grade(gnl) <= state.maxGrade, state.gradesAndLabels))

@react.component
let make = (~evaluationCriterion, ~courseId, ~addOrUpdateCriterionCB) => {
  let (state, setState) = React.useState(() =>
    switch evaluationCriterion {
    | None => {
        name: "",
        maxGrade: 5,
        gradesAndLabels: Array.of_list(List.map(i => GradeLabel.empty(i), possibleGradeValues)),
        saving: false,
        dirty: false,
      }
    | Some(ec) => {
        name: EvaluationCriterion.name(ec),
        maxGrade: EvaluationCriterion.maxGrade(ec),
        gradesAndLabels: EvaluationCriterion.gradesAndLabels(ec),
        saving: false,
        dirty: false,
      }
    }
  )
  <div className="mx-auto bg-white">
    <div className="max-w-2xl p-6 mx-auto">
      <h5 className="uppercase text-center border-b border-gray-300 pb-2">
        {str(
          switch evaluationCriterion {
          | None => t("add_criterion")
          | Some(ec) => EvaluationCriterion.name(ec)
          },
        )}
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
              {str(ts("name"))}
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
              active={state.dirty && String.length(String.trim(state.name)) < 1}
            />
          </div>
        </div>
        <div className="mx-auto">
          <div className="max-w-2xl pt-6 mx-auto">
            <div className="mb-4">
              <span
                className="inline-block tracking-wide text-sm font-semibold me-2"
                htmlFor="max_grades">
                {str(t("max_grade"))}
              </span>
              {switch evaluationCriterion {
              | Some(_) =>
                <span
                  className="cursor-not-allowed inline-block bg-white border-b-2 text-2xl font-semibold text-center border-blue px-3 py-2 leading-tight rounded-none focus:outline-none">
                  {str(string_of_int(state.maxGrade))}
                </span>
              | None =>
                <select
                  onChange={event =>
                    updateMaxGrade(int_of_string(ReactEvent.Form.target(event)["value"]), setState)}
                  id="max_grade"
                  value={string_of_int(state.maxGrade)}
                  className="cursor-pointer inline-block appearance-none bg-white border-b-2 text-2xl font-semibold text-center border-blue hover:border-blue-500 px-3 py-2 leading-tight rounded-none focus:outline-none focus:border-focusColor-500">
                  {React.array(
                    Array.of_list(
                      List.map(
                        possibleGradeValue =>
                          <option
                            key={string_of_int(possibleGradeValue)}
                            value={string_of_int(possibleGradeValue)}>
                            {str(string_of_int(possibleGradeValue))}
                          </option>,
                        possibleGradeValues,
                      ),
                    ),
                  )}
                </select>
              }}
            </div>
            <div className="flex justify-between">
              <div className="flex items-center">
                <label className="block tracking-wide text-xs font-semibold" htmlFor="grades">
                  {str(t("grade_labels.label"))}
                </label>
                <HelpIcon className="ms-2" link={t("grade_labels.help_url")}>
                  {str(t("grade_labels.help"))}
                </HelpIcon>
              </div>
            </div>
            <div ariaLabel="label-editor"> {React.array(labels(state, setState))} </div>
            <div className="mt-3 mb-3 text-xs">
              <span className="leading-normal">
                <strong> {str(t("important") ++ ":")} </strong>
                {str(" " ++ t("important_details"))}
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
                  {str(t("update_criterion"))}
                </button>

              | None =>
                <button
                  disabled={saveDisabled(state)}
                  onClick={_ =>
                    createEvaluationCriterion(state, setState, addOrUpdateCriterionCB, courseId)}
                  className="w-full btn btn-large btn-primary mt-3">
                  {str(t("create_criterion"))}
                </button>
              }}
            </div>
          </div>
        </div>
      </DisablingCover>
    </div>
  </div>
}
