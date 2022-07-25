type resourceType =
  | Target
  | TargetGroup

module SortResourceMutation = %graphql(`
   mutation SortCurriculumResourcesMutation($resourceIds: [ID!]!, $resourceType: String!) {
    sortCurriculumResources(resourceIds: $resourceIds, resourceType: $resourceType){
      success
    }
  }
   `)

let resourceTypeToString = resourceType =>
  switch resourceType {
  | Target => "Target"
  | TargetGroup => "TargetGroup"
  }

let sort = (resourceType, resourceIds) =>
  SortResourceMutation.make(
    ~notify=false,
    {
      resourceIds: resourceIds,
      resourceType: resourceTypeToString(resourceType),
    },
  )
  |> Js.Promise.then_(_response => Js.Promise.resolve())
  |> ignore
