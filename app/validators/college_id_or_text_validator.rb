class CollegeIdOrTextValidator < ActiveModel::Validator
  def validate(record)
    return if record.college_id.present? && record.college_id != 'other'
    return if record.college_text.present?

    record.errors[:base] << 'College is missing.'

    if record.college_id == 'other'
      record.errors[:college_text] << "can't be blank"
    else
      record.errors[:college_id] << 'must be selected'
    end
  end
end
