let t = I18n.t(~scope="components.TopicsShow__SubscriptionManager")

let str = React.string

module CreateTopicSubscriptionQuery = %graphql(
  `
  mutation CreateTopicSubscriptionMutation($topicId: ID!) {
    createTopicSubscription(topicId: $topicId)  {
      success
    }
  }
`
)

module DeleteTopicSubscriptionQuery = %graphql(
  `
  mutation DeleteTopicSubscriptionMutation($topicId: ID!) {
    deleteTopicSubscription(topicId: $topicId) {
      success
    }
  }
  `
)

let iconClasses = (subscribed, saving) =>
  "fa-fw" ++ if saving {
    " fas fa-bell text-primary-200"
  } else if subscribed {
    " fas fa-bell-slash cursor-pointer text-red-400"
  } else {
    " far fa-bell cursor-pointer"
  }

let handleSubscription = (
  saving,
  subscribed,
  setSaving,
  topicId,
  subscribeCB,
  unsubscribeCB,
  event,
) => {
  event |> ReactEvent.Mouse.preventDefault
  saving
    ? ()
    : {
        setSaving(_ => true)
        if subscribed {
          DeleteTopicSubscriptionQuery.make(~topicId, ())
          |> GraphqlQuery.sendQuery
          |> Js.Promise.then_(response => {
            response["deleteTopicSubscription"]["success"]
              ? {
                  unsubscribeCB()
                  setSaving(_ => false)
                }
              : setSaving(_ => false)
            Js.Promise.resolve()
          })
          |> Js.Promise.catch(_ => {
            setSaving(_ => false)
            Js.Promise.resolve()
          })
          |> ignore
        } else {
          CreateTopicSubscriptionQuery.make(~topicId, ())
          |> GraphqlQuery.sendQuery
          |> Js.Promise.then_(response => {
            response["createTopicSubscription"]["success"]
              ? {
                  subscribeCB()
                  setSaving(_ => false)
                }
              : setSaving(_ => false)
            Js.Promise.resolve()
          })
          |> Js.Promise.catch(_ => {
            setSaving(_ => false)
            Js.Promise.resolve()
          })
          |> ignore
        }
      }
}

@react.component
let make = (~topicId, ~subscribed, ~subscribeCB, ~unsubscribeCB) => {
  let (saving, setSaving) = React.useState(() => false)
  <button
    disabled=saving
    onClick={handleSubscription(saving, subscribed, setSaving, topicId, subscribeCB, unsubscribeCB)}
    className="inline-flex items-center font-semibold p-2 md:py-1 bg-gray-100 hover:bg-gray-300 border rounded text-xs flex-shrink-0">
    <FaIcon classes={iconClasses(subscribed, saving)} />
    <span className="ml-2"> {str(subscribed ? t("unsubscribe") : t("subscribe"))} </span>
  </button>
}
