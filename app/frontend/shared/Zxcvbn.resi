type t

let make: (~userInputs: array<string>=?, ~password: string) => option<t>

let label: t => string
let colorClass: (t, int) => string
let suggestions: t => array<string>
let score: t => int
