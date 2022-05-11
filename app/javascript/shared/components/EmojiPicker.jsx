import React, { useEffect, useRef, useState } from "react";
import { Picker } from "emoji-mart";
import data from "@emoji-mart/data";

export default function EmojiPicker(props) {
  const ref = useRef();
  const wrapperRef = useRef()
  const [isOpen, setIsOpen] = useState(false);
  useEffect(() => {
    new Picker({
      ...props,
      data,
      ref,
      theme: "light",
      onEmojiSelect: props?.onChange,
    });

    const handleClickOutside = (event) => {
      if (wrapperRef.current && !wrapperRef.current.contains(event.target)) {
        setIsOpen(false)
      }
    };

    const handleEscKey = (e) => {
      if (e.key == 'Escape' || e.key == 'Esc' || e?.keyCode == 27) {
        setIsOpen(false)
      }
    };

    document.addEventListener('keyup', handleEscKey)
    document.addEventListener('click', handleClickOutside, true);
    return () => {
      document.removeEventListener('click', handleClickOutside, true);
      document.removeEventListener('keyup', handleEscKey, true);

    };

  }, []);

  return (
    <div className="relative inline-block" ref={wrapperRef}>
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
