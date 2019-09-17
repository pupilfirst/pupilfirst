type resourceType =
  | Target
  | TargetGroup;

module SortResourceMutation = [%graphql
  {|
   mutation($resourceIds: [ID!]!, $resourceType: String!) {
    sortCurriculumResources(resourceIds: $resourceIds, resourceType: $resourceType){
      success
    }
  }
   |}
];

let resourceTypeToString = resourceType =>
  switch (resourceType) {
  | Target => "Target"
  | TargetGroup => "TargetGroup"
  };

let sort = (resourceType, authenticityToken, resourceIds) =>
  SortResourceMutation.make(
    ~resourceIds,
    ~resourceType=resourceTypeToString(resourceType),
    (),
  )
  |> GraphqlQuery.sendQuery(authenticityToken, ~notify=false)
  |> Js.Promise.then_(_response => Js.Promise.resolve())
  |> ignore;
