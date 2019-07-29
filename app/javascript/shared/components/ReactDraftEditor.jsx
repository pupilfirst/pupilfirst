import React from 'react';
import { Editor, EditorState, ContentState } from 'draft-js';

const onChange = (onChangeCB, setEditorState, editorState) => {
  const text = editorState.getCurrentContent().getPlainText();
  onChangeCB(text);
  setEditorState(editorState)
};

export default function ReactDraftEditor(props) {
  const [editorState, setEditorState] = React.useState(() => {
    const contentState = ContentState.createFromText(props.content);
    return EditorState.createWithContent(contentState);
  }
  );

  const editor = React.useRef(null);

  function focusEditor() {
    editor.current.focus();
  }

  React.useEffect(() => {
    focusEditor()
  }, []);

  return (
    <div onClick={focusEditor} style={{ minHeight: "10rem" }}>
      <Editor
        ref={editor}
        editorState={editorState}
        onChange={editorState => onChange(props.onChange, setEditorState, editorState)}
      />
    </div>
  );
};
