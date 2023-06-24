let str = React.string

let tr = I18n.t(~scope="components.CommunitiesNewTopic__Root")
let ts = I18n.t(~scope="shared")

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
    let similar = title |> String.trim == "" ? {search: "", suggestions: []} : state.similar

    {...state, title: title, similar: similar}
  | UpdateTitleAndTimeout(title, timeoutId) => {
      ...state,
      title: title,
      titleTimeoutId: Some(timeoutId),
    }
  | UpdateBody(body) => {...state, body: body}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | BeginSearching => {...state, searching: true}
  | FinishSearching(search, suggestions) => {
      ...state,
      searching: false,
      similar: {
        search: search,
        suggestions: suggestions,
      },
    }
  | FailSearching => {...state, searching: false}
  | SelectCategory(selectedCategory) => {...state, selectedCategory: selectedCategory}
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

  let trimmedTitle = title |> String.trim

  SimilarTopicsQuery.make({
    communityId: communityId,
    title: trimmedTitle,
  })
  |> Js.Promise.then_(result => {
    let suggestions = result["similarTopics"]->Js.Array2.map(TopicSuggestion.makeFromJs)
    send(FinishSearching(trimmedTitle, suggestions))
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(e => {
    Js.log(e)
    Notification.warn(tr("oops"), tr("failed_fetch_similar"))
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let isInvalidString = s => s |> String.trim == ""

let updateTitleAndSearch = (state, send, communityId, title) => {
  state.titleTimeoutId->Belt.Option.forEach(Js.Global.clearTimeout)

  let trimmedTitle = title |> String.trim

  if title |> isInvalidString || trimmedTitle == state.similar.search {
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

let saveDisabled = state => state.body |> isInvalidString || state.title |> isInvalidString

let handleCreateTopic = (state, send, communityId, target, topicCategory, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if !saveDisabled(state) {
    send(BeginSaving)
    let targetId = target |> OptionUtils.flatMap(TopicsShow__LinkedTarget.id)

    let topicCategoryId = topicCategory |> OptionUtils.flatMap(tc => Some(TopicCategory.id(tc)))

    CreateTopicQuery.fetch({
      body: state.body,
      title: state.title,
      communityId: communityId,
      targetId: targetId,
      topicCategoryId: topicCategoryId,
    })
    |> Js.Promise.then_((response: CreateTopicQuery.t) => {
      switch response.createTopic.topicId {
      | Some(topicId) =>
        Notification.success(tr("done"), tr("redirecting"))
        redirectToNewTopic(topicId, state.title)

      | None => send(FailSaving)
      }

      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Js.log(error)
      Notification.error(ts("notifications.unexpected_error"), tr("please_reload"))
      Js.Promise.resolve()
    })
    |> ignore
  } else {
    Notification.error(tr("missing_info"), tr("topic_body_present"))
  }
}

let suggestions = state => {
  let suggestions = state.similar.suggestions

  suggestions |> ArrayUtils.isNotEmpty
    ? <div className="pt-3">
        <span className="tracking-wide text-gray-900 text-xs font-semibold">
          {tr("similar_topics") |> str}
        </span>
        {state.searching
          ? <span className="ms-2"> <FaIcon classes="fa fa-spinner fa-pulse" /> </span>
          : React.null}
        {suggestions->Js.Array2.map(suggestion => {
          let askedOn =
            suggestion->TopicSuggestion.createdAt->DateFns.formatPreset(~short=true, ~year=true, ())
          let (answersText, answersClasses) = switch suggestion |> TopicSuggestion.repliesCount {
          | 0 => (tr("no_replies"), "bg-gray-300 text-gray-600")
          | 1 => (tr("one_reply"), "bg-green-500 text-white")
          | n => ((n |> string_of_int) ++ tr("count_replies_label"), "bg-green-500 text-white")
          }

          <a
            href={"/topics/" ++
            ((suggestion |> TopicSuggestion.id) ++
            ("/" ++ (suggestion |> TopicSuggestion.title |> StringUtils.parameterize)))}
            target="_blank"
            key={suggestion |> TopicSuggestion.id}
            className="flex w-full items-center justify-between mt-1 p-3 rounded cursor-pointer border bg-gray-50 hover:text-primary-500 hover:bg-gray-50">
            <div className="flex flex-col min-w-0">
              <h5
                title={suggestion |> TopicSuggestion.title}
                className="font-semibold text-sm leading-snug md:text-base pe-1 truncate flex-1">
                {suggestion |> TopicSuggestion.title |> str}
              </h5>
              <p className="text-xs mt-1 leading-tight text-gray-800">
                {tr("asked_on") ++ askedOn |> str}
              </p>
            </div>
            <div
              className={"text-xs px-1 py-px ms-2 rounded font-semibold shrink-0 " ++
              answersClasses}>
              {answersText |> str}
            </div>
          </a>
        }) |> React.array}
      </div>
    : React.null
}

let searchingIndicator = state =>
  state.similar.suggestions |> ArrayUtils.isEmpty && state.searching
    ? <div className="md:flex-1 ps-1 pb-3 md:p-0">
        <FaIcon classes="fas fa-spinner fa-pulse" />
      </div>
    : React.null

let handleSelectTopicCategory = (send, topicCategories, event) => {
  let target = event |> ReactEvent.Form.target

  let selectedCategory = switch target["value"] {
  | "not_selected" => None
  | selectedCategoryId =>
    Some(
      topicCategories |> ArrayUtils.unsafeFind(
        category => TopicCategory.id(category) == selectedCategoryId,
        tr("no_category_found") ++ selectedCategoryId,
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
              <span className="ms-2"> {tr("back") |> str} </span>
            </a>
          </div>
        </div>
        {switch target {
        | Some(target) =>
          <div className="max-w-3xl w-full mt-5 mx-auto px-3 lg:px-0">
            <div
              className="flex py-4 px-4 md:px-5 w-full bg-white border border-primary-500  shadow-md rounded-lg justify-between items-center mb-2">
              <p className="w-3/5 md:w-4/5 text-sm">
                <span className="font-semibold block text-xs"> {tr("linked_target") |> str} </span>
                <span> {target |> TopicsShow__LinkedTarget.title |> str} </span>
              </p>
              <a href="./new_topic" className="btn btn-default"> {tr("clear") |> str} </a>
            </div>
          </div>
        | None => React.null
        }}
        <h4 className="max-w-3xl w-full mx-auto pb-2 mt-2 px-3 lg:px-0">
          {tr("create_topic_discussion") |> str}
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
                    {tr("title") |> str}
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
                      {tr("select_category") |> str}
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
                          {TopicCategory.name(category) |> str}
                        </option>
                      )
                      ->Js.Array2.concat(
                        [
                          <option key="not_selected" value="not_selected">
                            {tr("not_selected") |> str}
                          </option>,
                        ],
                        _,
                      )
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
                {tr("body") |> str}
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
                      {tr("create_topic") |> str}
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
