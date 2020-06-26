[@react.component]
let make = (~schoolName, ~emailSenderSignature) => {
  <div className="px-6 mt-6 max-w-3xl mx-auto">
    <SchoolsConfiguration__SenderSignatureForm
      schoolName
      emailSenderSignature
    />
    <hr className="mt-4" />
  </div>;
};
