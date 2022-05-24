type kind = HeaderLink | FooterLink | SocialLink

type state = {
  kind: kind,
  title: string,
  url: string,
  titleInvalid: bool,
  urlInvalid: bool,
  formDirty: bool,
  adding: bool,
  deleting: list<SchoolCustomize__Customizations.linkId>,
}

type action =
  | UpdateKind(kind)
  | UpdateTitle(string, bool)
  | UpdateUrl(string, bool)
  | DisableForm
  | EnableForm
  | ClearForm
  | DisableDelete(SchoolCustomize__Customizations.linkId)
