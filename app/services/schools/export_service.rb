module Schools
  class ExportService
    EXPORTABLES = %i[courses users]

    def initialize(export)
      @export = export
      @school = export.school
      @base_dir = Dir.tmpdir
      @suffix_hash =
        Digest::SHA256.hexdigest(Time.current.to_s + @school.id.to_s)
      @export_rules = ExportRules.new(@school)
    end

    def export
      exportable_tables = EXPORTABLES & @export.tables.map(&:to_sym)

      if exportable_tables.blank?
        raise "Please specify tables that needs to be exported."
      end

      file_names = []

      exportable_tables.each do |table_name|
        file_names << table_to_file(table_name)
      end

      zipped_file_path = zip_files(file_names)

      update_export(zipped_file_path)

      delete_files(file_names << zipped_file_path)
    end

    private

    def table_to_file(table_name)
      file_name = "#{table_name}_#{@suffix_hash}.cvs"

      rule = @export_rules.rule(table_name)

      columns = rule[:columns]
      scope = rule[:scope]

      model = table_name.to_s.classify.constantize

      scope.call(model).copy_to(
        File.join(@base_dir, file_name),
        columns: columns
      )

      file_name
    end

    def zip_files(file_names)
      zip_file_path =
        File.join(@base_dir, "#{@school.name}-#{@suffix_hash}.zip")
      Zip::File.open(zip_file_path, create: true) do |zipfile|
        file_names.each do |file_name|
          absolute_file_path = File.join(@base_dir, file_name)
          if File.exist?(absolute_file_path)
            zipfile.add(file_name, absolute_file_path)
          else
            Rails.logger.error(
              "Expected file #{absolute_file_path} was not found."
            )
          end
        end
      end

      zip_file_path
    end

    def update_export(zip_file_path)
      @export.file.attach(
        io: File.open(zip_file_path),
        filename: "#{@school.name}-export.zip"
      )
      @export.save!
    end

    def courses
      file_name = "courses_#{@suffix_hash}.cvs"

      @school.courses.copy_to(File.join(@base_dir, file_name))

      file_name
    end

    def delete_files(file_names)
      file_names.each do |file_name|
        FileUtils.rm_f(File.join(@base_dir, file_name))
      end
    end
  end

  class ExportRules
    def initialize(school)
      @school = school
    end

    def rule(table_name)
      method_name = :"#{table_name}_rule"

      self.send(method_name)
    end

    private

    def courses_rule
      { columns: nil, scope: ->(_) { @school.courses } }
    end

    def users_rule
      excluded_columns = %i[
        api_token_digest
        confirmed_at
        current_sign_in_at
        encrypted_password
        last_sign_in_at
        login_token
        login_token_digest
        login_token_generated_at
        remember_created_at
        remember_token
        reset_password_sent_at
        reset_password_token
        sign_in_count
        sign_out_at_next_request
        webpush_subscription
      ]

      {
        columns: User.column_names.map(&:to_sym) - excluded_columns,
        scope: ->(_) { @school.users }
      }
    end
  end
end
