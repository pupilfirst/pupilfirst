module FacultyHelper
  def faculty_image_path(type, image)
    "faculty/#{type}/". #Images are stored in a subfolder in faculty/
    +(image).
      gsub('Dr. ', ''). #Remove Salutations
    gsub('.', '_'). #Convert initials to underscores
    gsub(' ', '_'). #Convert spaces to underscores
    underscore. #Convert to underscore case
    gsub(/_+/, '_'). #Convert multiple underscores to one
    +('.png') #PNG image
  end
end
