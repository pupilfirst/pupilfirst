type intlDisplayNames

@send external intlDisplayNameOf: (intlDisplayNames, string) => string = "of"

@new
external createIntlDisplayNames: (array<string>, {"type": string}) => intlDisplayNames =
  "Intl.DisplayNames"

let toLanguageName = (inputLanguage, outputLanguage) => {
  let intlDisplayNames = createIntlDisplayNames([outputLanguage], {"type": "language"})
  intlDisplayNameOf(intlDisplayNames, inputLanguage)
}

let humanize = languageCode =>
  if languageCode->Js.String2.startsWith("en") {
    toLanguageName(languageCode, languageCode)
  } else {
    toLanguageName(languageCode, "en") ++ " - " ++ toLanguageName(languageCode, languageCode)
  }
