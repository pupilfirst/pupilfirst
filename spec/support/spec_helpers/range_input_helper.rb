module RangeInputHelper
  def select_from_range(ctx, id, value)
    script = <<~SCRIPT
      var input = document.getElementById('#{id}')
      var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set;
      nativeInputValueSetter.call(input, #{value.is_a?(Numeric) ? value : "'#{value}'"});
      var inputEvent = new Event('input', { bubbles: true});
      input.dispatchEvent(inputEvent);
    SCRIPT

    ctx.execute_script(script)
  end
end
