module type X = {
  module Raw: {
    type t
    type t_variables
  }
  type t
  type t_variables

  let query: string
  let parse: Raw.t => t
  let serialize: t => Raw.t
  let serializeVariables: t_variables => Raw.t_variables
  let variablesToJson: Raw.t_variables => Js.Json.t
  let makeVariables: Js.t<'a> = "%identity" => t_variables
}

// module type GraphQLQuery = {
//   module Raw: {
//     type t
//   }
//   type t
//   let query: string
//   /* this just makes sure it's just a type conversion, and no function have
//    to be called */
//   external unsafe_fromJson: Js.Json.t => Raw.t = "%identity"
//   let parse: Raw.t => t
// }
module Extender = (M: X) => {
  let make = (~variables, ()) => {
    {
      "query": M.query,
      "parse": M.parse,
      "variables": M.makeVariables(variables)->M.serializeVariables->M.variablesToJson,
    }
  }
}
