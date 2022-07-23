let nullUnless = (element, condition) => condition ? element : React.null

let nullIf = (element, condition) => nullUnless(element, !condition)
