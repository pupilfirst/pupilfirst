module UsersHelper
  def startup_html(startup)
    if startup.present?
      link_to startup.try(:name), startup_url(startup)
    else
      '<em>Not member of a Startup yet</em>'.html_safe
    end
  end

  def value_or_not_available(value)
    if value.blank?
      '<em>Not Available</em>'.html_safe
    else
      value
    end
  end

  def educational_qualification_html(qualification)
    case qualification
      when User::EDUCATIONAL_QUALIFICATION_BELOW_MATRICULATION
        'Below matriculation (< 10th)'
      when User::EDUCATIONAL_QUALIFICATION_MATRICULATION
        'Matriculation (10th)'
      when User::EDUCATIONAL_QUALIFICATION_HIGHER_SECONDARY
        'Higher Secondary (12th)'
      when User::EDUCATIONAL_QUALIFICATION_GRADUATE
        'Graduate'
      when User::EDUCATIONAL_QUALIFICATION_POSTGRADUATE
        'Postgraduate'
      else
        '<em>Unknown</em>'.html_safe
    end
  end

  def religion_html(religion)
    case religion
      when User::RELIGION_HINDU
        'Hindu'
      when User::RELIGION_MUSLIM
        'Muslim'
      when User::RELIGION_CHRISTIAN
        'Christian'
      when User::RELIGION_SIKH
        'Sikh'
      when User::RELIGION_BUDDHIST
        'Buddhist'
      when User::RELIGION_JAIN
        'Jain'
      when User::RELIGION_OTHER
        'Other'
      else
        '<em>Unknown</em>'.html_safe
    end
  end

  def generate_sep_pdf(out_file, profile_pic, signature, data={})
    require "prawn"

    Prawn::Document.generate(out_file) do
      font "Times-Roman"
      font_size 18
      text "<u>Nodal Agency Certification Form</u>", align: :center, inline_format: true
      text "Request for award of Grace marks and Attendance as per the Student Entrepreneurship"
      text "Policy [G.O. (Rt.) NO: 1818/2013/H.Edn dated 04/09/2013, Thiruvananthapuram"
      text "<br /><br />", inline_format: true
      bounding_box([10, cursor], :width => 100, :height => 100) do |position|
        image profile_pic, position: position, scale: 0.5
        transparent(0.5) { stroke_bounds }
      end
      text "<br /><br />", inline_format: true
      text "Name of the Application : #{data[:fullname]}"
      text "Date of Birth : #{data[:born_on]}"
      text "Gender : #{data[:gender]}"
      text "College : #{data[:college]}"
      text "Course : #{data[:course]}"
      text "Concerned Nodal Agency : Startup Village"
      text "Name of the Incubated Company : #{data[:company_name]}"
      text "Designation of the applicant in the Incubated Company : #{data[:title]}"
      text "Semester Applying for: #{data[:semester]}"
      text "University : #{data[:university]}"
      text "University Registration ID/Roll No : #{data[:university_registration_number]}"
      text "Address - Home : #{data[:address]}"
      text "<br /><br />", inline_format: true
      text "The Startup Village being the Nodal Agency, hereby certifies that Mr/Ms. #{data[:fullname]} be awarded 1% Grace Marks and 5% attendance for the above semester applied for."
      text "<br /><br /><br /><br />", inline_format: true
      start_new_page
      text "<u>Concerning Authority at Nodal Agency/Incubator</u>", inline_format: true
      text "Name of the NOdal Agency : Startup Village"
      text "Name of the Concerned Authority :"
      text "Designation :"
      text "<br /><br />", inline_format: true
      bounding_box([10, cursor], :width => 150, :height => 150) do |position|
        image signature, position: position, scale: 0.5
        transparent(0.5) { stroke_bounds }
      end
      text "<br /><br />", inline_format: true
      text "(Affix Signature & Seal)"
      text "<br /><br /><br /><br />", inline_format: true
      text "Place : Ernakulam"
      text "Date : #{Time.now.to_date}"

    end

  end
end
