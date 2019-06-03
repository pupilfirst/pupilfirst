let sendQuery:
  (
    string,
    {
      ..
      "parse": Js.Json.t => 'a,
      "query": string,
      "variables": Js.Json.t,
    }
  ) =>
  Js.Promise.t('a);