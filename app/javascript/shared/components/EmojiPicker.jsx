import React, { useEffect, useRef, useState } from "react";
import { Picker } from "emoji-mart";
import data from "@emoji-mart/data";

export default function EmojiPicker(props) {
  const ref = useRef();
  const [isOpen, setIsOpen] = useState(false);
  useEffect(() => {
    new Picker({
      ...props,
      data,
      ref,
      theme: "light",
      onSelect: console.log,
      onClick: console.log,
      onSkinChange: console.log,
      onEmojiSelect: props?.onChange,
    });
  }, []);

  return (
    <div className="relative inline-block">
      <button
        aria-label={props?.title}
        title={props?.title}
        onClick={() => setIsOpen((prev) => !prev)}
        className={props?.className}
      >
        <i className="fas fa-smile" />
      </button>
      <div
        className={
          isOpen ? "absolute top-full left-full right-0 z-10 shadow" : "hidden"
        }
      >
        <div ref={ref} />
      </div>
    </div>
  );
}
