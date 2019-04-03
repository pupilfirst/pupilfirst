type t = Fetch.formData;

[@bs.new] external create : Dom.element => t = "FormData";

[@bs.send] external append : (t, 'a) => unit = "append";