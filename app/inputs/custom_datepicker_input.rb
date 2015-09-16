class CustomDatepickerInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    # The base input box.
    inputs = @builder.text_field(attribute_name, input_html_options)

    # The alternate hidden input box with correct format.
    inputs += @builder.hidden_field(attribute_name, class: "#{attribute_name}-alt")
    inputs.html_safe
  end
end
