module FacultyHelper
  def faculty_image_path(type, image)
    # Images are stored in a subfolder in faculty/
    path = "faculty/#{type}/#{image}"

    # Remove Salutations
    path.gsub!('Dr. ', '')

    # Convert initials and spaces to underscores
    path.tr!('. ', '_')

    # Convert to underscore case
    path = path.underscore

    # Convert multiple underscores to one
    path.gsub!(/_+/, '_')

    # PNG image
    path + '.png'
  end
end
