class DatetimePickerInput < DatePickerInput
  private

  def display_pattern
    I18n.t('datepicker.dformat', default: '%d/%m/%Y') + ' ' +
        I18n.t('timepicker.dformat', default: '%R')
  end

  def picker_pattern
    I18n.t('datepicker.pformat', default: 'DD/MM/YYYY') + ' ' +
        I18n.t('timepicker.pformat', default: 'HH:mm')
  end
end
