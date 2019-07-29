import React from 'react';
import { Editor, EditorState, ContentState, Modifier } from 'draft-js';

const onChange = (onChangeCB, setEditorState, editorState) => {
  const text = editorState.getCurrentContent().getPlainText();
  onChangeCB(text);
  setEditorState(editorState)
};

const handleKeyCommand = (onChangeCB, editorState, setEditorState, command) => {
  switch (command) {
    case "bold":
      setBold(onChangeCB, editorState, setEditorState);
      return 'handled';
    case "italic":
      setItalic(onChangeCB, editorState, setEditorState);
      return 'handled';
    default:
      return 'not-handled';
  }
};

const updateSelection = (editorState, delimiter, filler, onChangeCB, setEditorState) => {
  const selectionState = editorState.getSelection();
  const anchorKey = selectionState.getAnchorKey();

  if (anchorKey !== selectionState.getFocusKey()) {
    return
  }

  const currentContent = editorState.getCurrentContent();
  const currentContentBlock = currentContent.getBlockForKey(anchorKey);
  const start = selectionState.getStartOffset();
  const end = selectionState.getEndOffset();
  const selectedText = currentContentBlock.getText().slice(start, end);

  var newContentState;

  if (selectionState.isCollapsed()) {
    newContentState = Modifier.insertText(currentContent, selectionState, delimiter + filler + delimiter)
  } else {
    newContentState = Modifier.replaceText(currentContent, selectionState, delimiter + selectedText + delimiter)
  }

  const newEditorState = EditorState.push(editorState, newContentState, 'insert-characters');
  onChange(onChangeCB, setEditorState, newEditorState);
}

const setBold = (onChangeCB, editorState, setEditorState) => {
  updateSelection(editorState, '**', 'bold text', onChangeCB, setEditorState);
}

const setItalic = (onChangeCB, editorState, setEditorState) => {
  updateSelection(editorState, '*', 'italicized text', onChangeCB, setEditorState);
}

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

  React.useEffect(() => {
    handleKeyCommand(props.onChange, editorState, setEditorState, props.command)
  }, [props.command, props.commandAt]);

  return (
    <div placeholder={props.placeholder} onClick={focusEditor} style={{ minHeight: "10rem" }}>
      <Editor
        ref={editor}
        handleKeyCommand={(command, editorState) => handleKeyCommand(props.onChange, editorState, setEditorState, command)}
        editorState={editorState}
        onChange={editorState => onChange(props.onChange, setEditorState, editorState)}
      />
    </div>
  );
};
