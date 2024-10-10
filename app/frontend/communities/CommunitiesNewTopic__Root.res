let str = React.string

let tr = I18n.t(~scope="components.CommunitiesNewTopic__Root", ...)
let ts = I18n.t(~scope="shared", ...)

open CommunitiesNewTopic__Types

type similar = {
  search: string,
  suggestions: array<TopicSuggestion.t>,
}

type state = {
  title: string,
  titleTimeoutId: option<Js.Global.timeoutId>,
  similar: similar,
  searching: bool,
  body: string,
  selectedCategory: option<TopicCategory.t>,
  saving: bool,
}

let initialState = {
  title: "",
  body: "",
  titleTimeoutId: None,
  similar: {
    search: "",
    suggestions: [],
  },
  searching: false,
  selectedCategory: None,
  saving: false,
}

type action =
  | UpdateTitle(string)
  | UpdateTitleAndTimeout(string, Js.Global.timeoutId)
  | UpdateBody(string)
  | SelectCategory(option<TopicCategory.t>)
  | BeginSaving
  | FailSaving
  | BeginSearching
  | FinishSearching(string, array<TopicSuggestion.t>)
  | FailSearching

let reducer = (state, action) =>
  switch action {
  | UpdateTitle(title) =>
    let similar = String.trim(title) == "" ? {search: "", suggestions: []} : state.similar

    {...state, title, similar}
  | UpdateTitleAndTimeout(title, timeoutId) => {
      ...state,
      title,
      titleTimeoutId: Some(timeoutId),
    }
  | UpdateBody(body) => {...state, body}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | BeginSearching => {...state, searching: true}
  | FinishSearching(search, suggestions) => {
      ...state,
      searching: false,
      similar: {
        search,
        suggestions,
      },
    }
  | FailSearching => {...state, searching: false}
  | SelectCategory(selectedCategory) => {...state, selectedCategory}
  }

module SimilarTopicsQuery = %graphql(`
    query SimilarTopicsQuery($communityId: ID!, $title: String!) {
      similarTopics(communityId: $communityId, title: $title) {
        id
        title
        createdAt
        liveRepliesCount
      }
    }
  `)

let searchForSimilarTopics = (send, title, communityId, ()) => {
  send(BeginSearching)

  let trimmedTitle = String.trim(title)

  ignore(
    Js.Promise.catch(
      e => {
        Js.log(e)
        Notification.warn(tr("oops"), tr("failed_fetch_similar"))
        send(FailSaving)
        Js.Promise.resolve()
      },
      Js.Promise.then_(
        result => {
          let suggestions = result["similarTopics"]->Js.Array2.map(TopicSuggestion.makeFromJs)
          send(FinishSearching(trimmedTitle, suggestions))
          Js.Promise.resolve()
        },
        SimilarTopicsQuery.make({
          communityId,
          title: trimmedTitle,
        }),
      ),
    ),
  )
}

let isInvalidString = s => String.trim(s) == ""

let updateTitleAndSearch = (state, send, communityId, title) => {
  state.titleTimeoutId->Belt.Option.forEach(Js.Global.clearTimeout)

  let trimmedTitle = String.trim(title)

  if isInvalidString(title) || trimmedTitle == state.similar.search {
    send(UpdateTitle(title))
  } else {
    let timeoutId = Js.Global.setTimeout(
      searchForSimilarTopics(send, trimmedTitle, communityId),
      1500,
    )

    send(UpdateTitleAndTimeout(title, timeoutId))
  }
}

module CreateTopicQuery = %graphql(`
  mutation CreateTopicQuery($title: String!, $body: String!, $communityId: ID!, $targetId: ID, $topicCategoryId: ID) {
    createTopic(body: $body, title: $title, communityId: $communityId, targetId: $targetId, topicCategoryId: $topicCategoryId) {
      topicId
    }
  }
`)

let redirectToNewTopic = (id, title) => {
  let redirectPath = "/topics/" ++ (id ++ ("/" ++ StringUtils.parameterize(title)))
  open Webapi.Dom
  window->Window.setLocation(redirectPath)
}

let saveDisabled = state => isInvalidString(state.body) || isInvalidString(state.title)

let handleCreateTopic = (state, send, communityId, target, topicCategory, event) => {
  ReactEvent.Mouse.preventDefault(event)

  if !saveDisabled(state) {
    send(BeginSaving)
    let targetId = OptionUtils.flatMap(TopicsShow__LinkedTarget.id, target)

    let topicCategoryId = OptionUtils.flatMap(tc => Some(TopicCategory.id(tc)), topicCategory)

    ignore(
      Js.Promise.catch(
        error => {
          Js.log(error)
          Notification.error(ts("notifications.unexpected_error"), tr("please_reload"))
          Js.Promise.resolve()
        },
        Js.Promise.then_(
          (response: CreateTopicQuery.t) => {
            switch response.createTopic.topicId {
            | Some(topicId) =>
              Notification.success(tr("done"), tr("redirecting"))
              redirectToNewTopic(topicId, state.title)

            | None => send(FailSaving)
            }

            Js.Promise.resolve()
          },
          CreateTopicQuery.fetch({
            body: state.body,
            title: state.title,
            communityId,
            targetId,
            topicCategoryId,
          }),
        ),
      ),
    )
  } else {
    Notification.error(tr("missing_info"), tr("topic_body_present"))
  }
}

let suggestions = state => {
  let suggestions = state.similar.suggestions

  ArrayUtils.isNotEmpty(suggestions)
    ? <div className="pt-3">
        <span className="tracking-wide text-gray-900 text-xs font-semibold">
          {str(tr("similar_topics"))}
        </span>
        {state.searching
          ? <span className="ms-2">
              <FaIcon classes="fa fa-spinner fa-pulse" />
            </span>
          : React.null}
        {React.array(
          suggestions->Js.Array2.map(suggestion => {
            let askedOn =
              suggestion
              ->TopicSuggestion.createdAt
              ->DateFns.formatPreset(~short=true, ~year=true, ())
            let (answersText, answersClasses) = switch TopicSuggestion.repliesCount(suggestion) {
            | 0 => (tr("no_replies"), "bg-gray-300 text-gray-600")
            | 1 => (tr("one_reply"), "bg-green-500 text-white")
            | n => (string_of_int(n) ++ tr("count_replies_label"), "bg-green-500 text-white")
            }

            <a
              href={"/topics/" ++
              (TopicSuggestion.id(suggestion) ++
              ("/" ++ StringUtils.parameterize(TopicSuggestion.title(suggestion))))}
              target="_blank"
              key={TopicSuggestion.id(suggestion)}
              className="flex w-full items-center justify-between mt-1 p-3 rounded cursor-pointer border bg-gray-50 hover:text-primary-500 hover:bg-gray-50">
              <div className="flex flex-col min-w-0">
                <h5
                  title={TopicSuggestion.title(suggestion)}
                  className="font-semibold text-sm leading-snug md:text-base pe-1 truncate flex-1">
                  {str(TopicSuggestion.title(suggestion))}
                </h5>
                <p className="text-xs mt-1 leading-tight text-gray-800">
                  {str(tr("asked_on") ++ askedOn)}
                </p>
              </div>
              <div
                className={"text-xs px-1 py-px ms-2 rounded font-semibold shrink-0 " ++
                answersClasses}>
                {str(answersText)}
              </div>
            </a>
          }),
        )}
      </div>
    : React.null
}

let searchingIndicator = state =>
  ArrayUtils.isEmpty(state.similar.suggestions) && state.searching
    ? <div className="md:flex-1 ps-1 pb-3 md:p-0">
        <FaIcon classes="fas fa-spinner fa-pulse" />
      </div>
    : React.null

let handleSelectTopicCategory = (send, topicCategories, event) => {
  let target = ReactEvent.Form.target(event)

  let selectedCategory = switch target["value"] {
  | "not_selected" => None
  | selectedCategoryId =>
    Some(
      ArrayUtils.unsafeFind(
        category => TopicCategory.id(category) == selectedCategoryId,
        tr("no_category_found") ++ selectedCategoryId,
        topicCategories,
      ),
    )
  }

  send(SelectCategory(selectedCategory))
}

@react.component
let make = (~communityId, ~target, ~topicCategories) => {
  let (state, send) = React.useReducer(reducer, initialState)

  <DisablingCover disabled=state.saving>
    <div className="bg-gray-50 md:pt-18">
      <div className="flex-1 flex flex-col">
        <div className="px-3 lg:px-0">
          <div className="max-w-3xl w-full mx-auto mt-5 pb-2">
            <a className="btn btn-subtle" onClick={_ => DomUtils.goBack()}>
              <i className="fas fa-arrow-left rtl:rotate-180" />
              <span className="ms-2"> {str(tr("back"))} </span>
            </a>
          </div>
        </div>
        {switch target {
        | Some(target) =>
          <div className="max-w-3xl w-full mt-5 mx-auto px-3 lg:px-0">
            <div
              className="flex py-4 px-4 md:px-5 w-full bg-white border border-primary-500  shadow-md rounded-lg justify-between items-center mb-2">
              <p className="w-3/5 md:w-4/5 text-sm">
                <span className="font-semibold block text-xs"> {str(tr("linked_target"))} </span>
                <span> {str(TopicsShow__LinkedTarget.title(target))} </span>
              </p>
              <a href="./new_topic" className="btn btn-default"> {str(tr("clear"))} </a>
            </div>
          </div>
        | None => React.null
        }}
        <h4 className="max-w-3xl w-full mx-auto pb-2 mt-2 px-3 lg:px-0">
          {str(tr("create_topic_discussion"))}
        </h4>
        <div className="md:px-3">
          <div
            className="mb-8 max-w-3xl w-full mx-auto relative border-t border-b md:border-0 bg-white md:shadow md:rounded-lg">
            <div className="flex w-full flex-col p-3 md:p-6">
              <div className="flex">
                <div className="flex-1 me-2">
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold mb-2"
                    htmlFor="title">
                    {str(tr("title"))}
                  </label>
                  <input
                    id="title"
                    tabIndex=1
                    value=state.title
                    className="appearance-none block w-full bg-white text-gray-900 font-semibold border border-gray-300 rounded py-3 px-4 mb-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                    onChange={event => {
                      let newTitle = ReactEvent.Form.target(event)["value"]
                      updateTitleAndSearch(state, send, communityId, newTitle)
                    }}
                    placeholder={tr("title_placeholder")}
                  />
                </div>
                {ReactUtils.nullIf(
                  <div className="md:w-1/4">
                    <label
                      className="inline-block tracking-wide text-gray-900 text-xs font-semibold mb-2"
                      htmlFor="topic_category">
                      {str(tr("select_category"))}
                    </label>
                    <select
                      id="topic_category"
                      value={switch state.selectedCategory {
                      | Some(category) => TopicCategory.id(category)
                      | None => ""
                      }}
                      className="appearance-none block w-full bg-white text-gray-900 font-semibold border border-gray-300 rounded py-3 px-4 mb-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                      onChange={handleSelectTopicCategory(send, topicCategories)}>
                      {topicCategories
                      ->Js.Array2.map(category =>
                        <option key={TopicCategory.id(category)} value={TopicCategory.id(category)}>
                          {str(TopicCategory.name(category))}
                        </option>
                      )
                      ->(Js.Array2.concat(
                        [
                          <option key="not_selected" value="not_selected">
                            {str(tr("not_selected"))}
                          </option>,
                        ],
                        _,
                      ))
                      ->React.array}
                    </select>
                  </div>,
                  ArrayUtils.isEmpty(topicCategories),
                )}
                <div />
              </div>
              <label
                className="inline-block tracking-wide text-gray-900 text-xs font-semibold mb-2"
                htmlFor="body">
                {str(tr("body"))}
              </label>
              <div className="w-full flex flex-col">
                <MarkdownEditor
                  tabIndex=2
                  textareaId="body"
                  onChange={markdown => send(UpdateBody(markdown))}
                  value=state.body
                  placeholder={tr("be_descriptive")}
                  profile=Markdown.Permissive
                  maxLength=10000
                />
                <div>
                  {suggestions(state)}
                  <div
                    className="flex flex-col md:flex-row justify-end mt-3 items-center md:items-start">
                    {searchingIndicator(state)}
                    <button
                      tabIndex=3
                      disabled={saveDisabled(state)}
                      onClick={handleCreateTopic(
                        state,
                        send,
                        communityId,
                        target,
                        state.selectedCategory,
                      )}
                      className="btn btn-primary border border-transparent w-full md:w-auto">
                      {str(tr("create_topic"))}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </DisablingCover>
}
