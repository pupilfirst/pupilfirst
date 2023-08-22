type t

let make: (~userInputs: array<string>=?, ~password: string) => t

let label: t => string
let color: t => string
let suggestions: t => array<string>
let score: t => int
