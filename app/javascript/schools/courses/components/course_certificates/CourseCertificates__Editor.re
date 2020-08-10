open CourseCertificates__Types;

let str = React.string;
let t = I18n.t(~scope="components.CourseCertificates__Editor");

type state = {
  margin: int,
  fontSize: int,
  nameOffsetTop: int,
  qrCorner: IssuedCertificate.qrCorner,
  qrScale: int,
};

type action =
  | UpdateMargin(int)
  | UpdateFontSize(int)
  | UpdateNameOffsetTop(int)
  | UpdateQrCorner(IssuedCertificate.qrCorner)
  | UpdateQrScale(int);

let computeInitialState = certificate => {
  margin: Certificate.margin(certificate),
  fontSize: Certificate.fontSize(certificate),
  nameOffsetTop: Certificate.nameOffsetTop(certificate),
  qrCorner: Certificate.qrCorner(certificate),
  qrScale: Certificate.qrScale(certificate),
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateMargin(margin) => {...state, margin}
  | UpdateFontSize(fontSize) => {...state, fontSize}
  | UpdateNameOffsetTop(nameOffsetTop) => {...state, nameOffsetTop}
  | UpdateQrCorner(qrCorner) => {...state, qrCorner}
  | UpdateQrScale(qrScale) => {...state, qrScale}
  };

let buttonTypeClass = (stateQrCorner, qrCorner) => {
  stateQrCorner == qrCorner ? "btn-primary" : "btn-default";
};

[@react.component]
let make = (~course, ~certificate, ~verifyImageUrl, ~closeDrawerCB) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, certificate, computeInitialState);

  let demoCertificate =
    IssuedCertificate.make(
      ~serialNumber="20201231-A1B2C3",
      ~issuedTo="Rosalind Wilton Oberbrunner",
      ~issuedAt=Js.Date.make(),
      ~courseName="Test Course",
      ~imageUrl=Certificate.imageUrl(certificate),
      ~margin=state.margin,
      ~fontSize=state.fontSize,
      ~nameOffsetTop=state.nameOffsetTop,
      ~qrCorner=state.qrCorner,
      ~qrScale=state.qrScale,
    );

  <SchoolAdmin__EditorDrawer
    closeDrawerCB
    closeButtonTitle={t("cancel")}
    size=SchoolAdmin__EditorDrawer.Large>
    <div className="flex flex-col min-h-screen">
      <div className="bg-white flex-grow-0">
        <div className="max-w-4xl px-6 pt-5 mx-auto">
          <h5 className="uppercase text-center border-b border-gray-400 pb-2">
            {t("edit_action")->str}
          </h5>
        </div>
        <div className="max-w-4xl px-6 py-6 mx-auto">
          <div className="flex">
            <div className="w-2/3">
              <IssuedCertificate__Root
                issuedCertificate=demoCertificate
                verifyImageUrl
              />
            </div>
            <div className="w-1/3 ml-4">
              <div>
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="margin">
                    {t("margin_label")->str}
                  </label>
                </div>
                <input
                  id="margin"
                  className="w-full mt-1"
                  type_="range"
                  name="margin"
                  min="0"
                  max="20"
                  value={string_of_int(state.margin)}
                  onChange={event =>
                    send(UpdateMargin(ReactEvent.Form.target(event)##value))
                  }
                />
              </div>
              <div className="mt-3">
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="name_offset_top">
                    {t("name_offset_top_label")->str}
                  </label>
                </div>
                <input
                  id="name_offset_top"
                  className="w-full mt-1"
                  type_="range"
                  name="name_offset_top"
                  min="0"
                  max="95"
                  value={string_of_int(state.nameOffsetTop)}
                  onChange={event =>
                    send(
                      UpdateNameOffsetTop(
                        ReactEvent.Form.target(event)##value,
                      ),
                    )
                  }
                />
              </div>
              <div className="mt-3">
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="font_size">
                    {t("font_size_label")->str}
                  </label>
                </div>
                <input
                  id="font_size"
                  className="w-full mt-1"
                  type_="range"
                  name="font_size"
                  min="75"
                  max="150"
                  value={string_of_int(state.fontSize)}
                  onChange={event =>
                    send(
                      UpdateFontSize(ReactEvent.Form.target(event)##value),
                    )
                  }
                />
              </div>
              <div className="mt-3">
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="qr_visibility">
                    {t("qr_visibility_label")->str}
                  </label>
                </div>
                <button
                  className={
                    "block btn mt-1 w-full "
                    ++ buttonTypeClass(state.qrCorner, `Hidden)
                  }
                  onClick={_ => send(UpdateQrCorner(`Hidden))}>
                  {t("qr_hidden_label")->str}
                </button>
                <div className="flex mt-2">
                  <button
                    className={
                      "btn w-1/2 mr-1 "
                      ++ buttonTypeClass(state.qrCorner, `TopLeft)
                    }
                    onClick={_ => send(UpdateQrCorner(`TopLeft))}>
                    {t("qr_top_left_label")->str}
                  </button>
                  <button
                    className={
                      "btn w-1/2 ml-1 "
                      ++ buttonTypeClass(state.qrCorner, `TopRight)
                    }
                    onClick={_ => send(UpdateQrCorner(`TopRight))}>
                    {t("qr_top_right_label")->str}
                  </button>
                </div>
                <div className="flex mt-2">
                  <button
                    className={
                      "btn w-1/2 mr-1 "
                      ++ buttonTypeClass(state.qrCorner, `BottomLeft)
                    }
                    onClick={_ => send(UpdateQrCorner(`BottomLeft))}>
                    {t("qr_bottom_left_label")->str}
                  </button>
                  <button
                    className={
                      "btn w-1/2 ml-1 "
                      ++ buttonTypeClass(state.qrCorner, `BottomRight)
                    }
                    onClick={_ => send(UpdateQrCorner(`BottomRight))}>
                    {t("qr_bottom_right_label")->str}
                  </button>
                </div>
              </div>
              {switch (state.qrCorner) {
               | `Hidden => React.null
               | `TopLeft
               | `TopRight
               | `BottomLeft
               | `BottomRight =>
                 <div className="mt-3">
                   <div>
                     <label
                       className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                       htmlFor="qr_scale">
                       {t("qr_scale_label")->str}
                     </label>
                   </div>
                   <input
                     id="qr_scale"
                     className="w-full mt-1"
                     type_="range"
                     name="qr_scale"
                     min="75"
                     max="150"
                     value={string_of_int(state.qrScale)}
                     onChange={event =>
                       send(
                         UpdateQrScale(ReactEvent.Form.target(event)##value),
                       )
                     }
                   />
                 </div>
               }}
            </div>
          </div>
        </div>
      </div>
      <div className="bg-gray-100 flex-grow">
        <div className="max-w-4xl p-6 mx-auto">
          <button disabled=true className="w-auto btn btn-large btn-primary">
            {t("save_changes")->str}
          </button>
        </div>
      </div>
    </div>
  </SchoolAdmin__EditorDrawer>;
};
