exception UnexpectedPathOnAuthorsInterface(list<string>)

let str = React.string

let t = I18n.t(~scope="components.CourseAuthors__Root")
let ts = I18n.ts

open CourseAuthors__Types

type state = {
  authors: array<Author.t>,
  deleting: bool,
}

type action =
  | BeginDeleting
  | FailToDelete
  | FinishDeleting(Author.t)
  | AddAuthor(Author.t)
  | UpdateAuthor(Author.t)

let reducer = (state, action) =>
  switch action {
  | BeginDeleting => {...state, deleting: true}
  | FailToDelete => {...state, deleting: false}
  | FinishDeleting(author) => {
      deleting: false,
      authors: state.authors |> Js.Array.filter(a => a |> Author.id != (author |> Author.id)),
    }
  | AddAuthor(author) => {
      ...state,
      authors: state.authors |> Js.Array.concat([author]),
    }
  | UpdateAuthor(author) => {
      ...state,
      authors: state.authors |> Array.map(a =>
        a |> Author.id == (author |> Author.id) ? author : a
      ),
    }
  }

module DeleteCourseAuthorQuery = %graphql(`
  mutation DeleteCourseAuthorMutation($id: ID!) {
    deleteCourseAuthor(id: $id) {
      success
    }
  }
`)

let removeCourseAuthor = (send, author, event) => {
  event |> ReactEvent.Mouse.preventDefault

  WindowUtils.confirm(
    t("window_confirm_pre") ++ " " ++ ((author |> Author.name) ++ " " ++ t("window_confirm_post")),
    () => {
      send(BeginDeleting)

      DeleteCourseAuthorQuery.fetch({id: Author.id(author)})
      |> Js.Promise.then_((response: DeleteCourseAuthorQuery.t) => {
        if response.deleteCourseAuthor.success {
          send(FinishDeleting(author))
        } else {
          send(FailToDelete)
        }

        Js.Promise.resolve()
      })
      |> Js.Promise.catch(_ => {
        send(FailToDelete)
        Js.Promise.resolve()
      })
      |> ignore
    },
  )
}

let renderAuthor = (rootPath, author, send) => {
  let authorPath = rootPath ++ ("/" ++ (author |> Author.id))
  <div key={author |> Author.id} className="flex w-1/2 shrink-0 mb-5 px-3">
    <div
      className="shadow bg-white rounded-lg flex w-full border border-transparent overflow-hidden hover:border-primary-400 hover:bg-gray-50 focus-within:outline-none focus-within:ring-2 focus-within:ring-focusColor-500">
      <a
        tabIndex=0
        ariaLabel={"View " ++ (author |> Author.name)}
        className="w-full cursor-pointer p-4 overflow-hidden focus:outline-none focus:bg-gray-50 focus:text-primary-500"
        href=authorPath
        onClick={event => {
          ReactEvent.Mouse.preventDefault(event)
          RescriptReactRouter.push(authorPath)
        }}>
        <div className="flex">
          <span className="me-4 shrink-0">
            {switch author |> Author.avatarUrl {
            | Some(avatarUrl) =>
              <img className="w-10 h-10 rounded-full object-cover" src=avatarUrl />
            | None => <Avatar name={author |> Author.name} className="w-10 h-10 rounded-full" />
            }}
          </span>
          <div className="flex flex-col">
            <span className="text-black font-semibold text-sm">
              {author |> Author.name |> str}
            </span>
            <span className="text-black font-normal text-xs">
              {author |> Author.email |> str}
            </span>
          </div>
        </div>
      </a>
      <button
        className="w-10 text-sm course-faculty__list-item-remove text-gray-600 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-50 hover:text-red-500 focus:outline-none focus:text-red-500 focus:bg-gray-50"
        title={ts("delete") ++ " " ++ (author |> Author.name)}
        ariaLabel={ts("delete") ++ " " ++ (author |> Author.name)}
        onClick={removeCourseAuthor(send, author)}>
        <i className="fas fa-trash-alt" />
      </button>
    </div>
  </div>
}

@react.component
let make = (~courseId, ~authors) => {
  let (state, send) = React.useReducer(reducer, {authors: authors, deleting: false})
  let rootPath = "/school/courses/" ++ (courseId ++ "/authors")

  <div className="flex min-h-full bg-gray-50">
    <div className="flex-1 flex flex-col">
      {
        let url = RescriptReactRouter.useUrl()
        switch url.path {
        | list{"school", "courses", _courseId, "authors"} => React.null
        | list{"school", "courses", _courseId, "authors", authorId} =>
          let author = if authorId == "new" {
            None
          } else {
            Some(
              state.authors |> ArrayUtils.unsafeFind(
                author => author |> Author.id == authorId,
                "Could not find author with ID " ++
                (authorId ++
                (" in the list of known authors for course with ID " ++ courseId)),
              ),
            )
          }

          <SchoolAdmin__EditorDrawer closeDrawerCB={_ => RescriptReactRouter.push(rootPath)}>
            <CourseAuthors__Form
              courseId
              rootPath
              author
              addAuthorCB={author => send(AddAuthor(author))}
              updateAuthorCB={author => send(UpdateAuthor(author))}
            />
          </SchoolAdmin__EditorDrawer>
        | otherPath => raise(UnexpectedPathOnAuthorsInterface(otherPath))
        }
      }
      <DisablingCover disabled=state.deleting message="Deleting...">
        <div className="flex px-6 py-2 items-center justify-between">
          <button
            onClick={_ => RescriptReactRouter.push(rootPath ++ "/new")}
            className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-primary-300 border-dashed hover:border-primary-300 focus:border-primary-300 focus:bg-gray-50 focus:text-primary-600 focus:shadow-lg p-6 rounded-lg mt-8 cursor-pointer">
            <i className="fas fa-plus-circle" />
            <h5 className="font-semibold ms-2"> {"Add New Author" |> str} </h5>
          </button>
        </div>
        <div className="px-6 pb-4 mt-5 flex">
          <div className="max-w-2xl w-full mx-auto">
            <div className="flex -mx-3 flex-wrap">
              {state.authors
              |> Author.sort
              |> Array.map(author => renderAuthor(rootPath, author, send))
              |> React.array}
            </div>
          </div>
        </div>
      </DisablingCover>
    </div>
  </div>
}
