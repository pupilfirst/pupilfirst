module UsersHelper

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
