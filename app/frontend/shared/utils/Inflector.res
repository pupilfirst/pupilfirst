@bs.module external pluralizeJs: (string, int, bool) => string = "pluralize"

let pluralize = (word, ~count=2, ~inclusive=false, ()) => pluralizeJs(word, count, inclusive)
