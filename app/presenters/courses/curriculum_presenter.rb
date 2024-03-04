module Courses
  class CurriculumPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "#{@course.name} | #{current_school.name}"
    end

    private

    def props
      if current_student.present?
        {
          submissions: submissions,
          targets_read: targets_read,
          student: student_details,
          coaches: faculty.map(&:attributes),
          users: users,
          evaluation_criteria: evaluation_criteria,
          preview: false,
          **default_props
        }
      else
        {
          submissions: [],
          targets_read: [],
          student: student_details_for_preview_mode,
          coaches: [],
          users: [],
          evaluation_criteria: [],
          preview: true,
          **default_props
        }
      end
    end

    def default_props
      {
        current_user: user_details,
        author: author?,
        course: course_details,
        levels: levels_details,
        target_groups: target_groups,
        targets: targets,
        access_locked_levels: access_locked_levels
      }
    end

    def user_details
      if current_user.present?
        {
          id: current_user.id,
          name: current_user.name,
          avatar_url: current_user.avatar_url(variant: :thumb),
          is_admin: current_school_admin.present?,
          is_author: @course.course_authors.exists?(user: current_user),
          is_coach: @course.faculty.exists?(user: current_user),
          is_student: current_student.present?
        }
      else
        user_details_for_preview_mode
      end
    end

    def user_details_for_preview_mode
      {
        id: "-1",
        name: current_user&.name || "John Doe",
        avatar_url: nil,
        is_admin: false,
        is_author: false,
        is_coach: false,
        is_student: false
      }
    end

    def author?
      return false if current_user.blank?

      current_school_admin.present? ||
        @course.course_authors.exists?(user: current_user)
    end

    def evaluation_criteria
      @course.evaluation_criteria.map do |ec|
        ec.attributes.slice("id", "name", "max_grade", "grade_labels")
      end
    end

    def student_details_for_preview_mode
      {
        name: current_user&.name || "John Doe",
        level_id: levels.first.id,
        ends_at: nil
      }
    end

    def student_details
      {
        name: current_student.name,
        level_id: level_id_for_student,
        ends_at: current_student.cohort.ends_at,
        completed_at: current_student.completed_at
      }
    end

    def level_id_for_student
      if current_student&.timeline_events.blank?
        return levels.where.not(number: 0).last.id
      end

      current_student.timeline_events.last.target.level.id
    end

    def course_details
      details =
        @course.attributes.slice(
          "id",
          "progression_behavior",
          "progression_limit"
        )

      if current_user.present?
        details.merge(
          certificate_serial_number:
            current_user
              .issued_certificates
              .live
              .joins(:course)
              .find_by(courses: { id: @course.id })
              &.serial_number,
          ended: @course.ended?
        )
      else
        details.merge(ended: @course.ended?)
      end
    end

    def levels
      @levels ||= @course.levels.order(number: :DESC).load
    end

    def levels_details
      levels.map do |level|
        level.attributes.slice("id", "name", "number", "unlock_at")
      end
    end

    def target_groups
      scope =
        @course
          .target_groups
          .where(level_id: open_level_ids)
          .where(archived: false)

      scope.map do |target_group|
        target_group.attributes.slice(
          "id",
          "level_id",
          "name",
          "description",
          "sort_index",
          "milestone"
        )
      end
    end

    def targets
      attributes = %w[id title target_group_id sort_index]

      scope =
        @course
          .targets
          .live
          .joins(:target_group)
          .includes(
            assignments: %i[evaluation_criteria prerequisite_assignments]
          )
          .where(target_groups: { level_id: open_level_ids })
          .where(archived: false)

      scope
        .select(*attributes)
        .map do |target|
          details = target.attributes.slice(*attributes)
          assignment = target.assignments.not_archived.first
          if assignment
            details[:role] = assignment.role
            details[:resubmittable] = assignment.checklist.present?
            details[:milestone] = assignment.milestone
            details[:reviewed] = assignment.evaluation_criteria.present?
            details[:has_assignment] = true
            details[
              :prerequisite_target_ids
            ] = assignment.prerequisite_assignments.pluck(:target_id)
          else
            details[:role] = Assignment::ROLE_STUDENT
            details[:resubmittable] = false
            details[:milestone] = false
            details[:reviewed] = false
            details[:has_assignment] = false
            details[:prerequisite_target_ids] = []
          end
          details
        end
    end

    def submissions
      current_student
        .latest_submissions
        .includes(target: :assignments)
        .map do |submission|
          if submission.target.individual_target? ||
               submission.student_ids.sort == current_student.team_student_ids
            submission.attributes.slice(
              "target_id",
              "passed_at",
              "evaluated_at"
            )
          end
        end - [nil]
    end

    def targets_read
      current_student.page_reads.pluck(:target_id).map(&:to_s)
    end

    def faculty
      @faculty ||=
        begin
          scope = Faculty.left_joins(:students, :courses)

          scope
            .where(students: { id: current_student })
            .or(scope.where(courses: { id: @course }))
            .distinct
            .select(:id, :user_id)
            .load
        end
    end

    def team_members_user_ids
      @team_members_user_ids ||=
        if current_student.team.present?
          current_student.team.students.pluck(:user_id)
        else
          [current_student.user_id]
        end
    end

    def users
      user_ids = (team_members_user_ids + faculty.pluck(:user_id)).uniq

      User
        .where(id: user_ids)
        .with_attached_avatar
        .map do |user|
          details = user.attributes.slice("id", "name", "title")
          details["avatar_url"] = user.avatar_url(variant: :thumb)
          details
        end
    end

    def current_student
      @current_student ||=
        if current_user.present?
          @course.students.not_dropped_out.find_by(user_id: current_user.id)
        else
          nil
        end
    end

    # Admins and coaches who have review access in this course have access to locked levels as well.
    def access_locked_levels
      @access_locked_levels ||=
        if current_user.present?
          current_school_admin.present? ||
            (
              current_user.faculty.present? &&
                CoursePolicy.new(pundit_user, @course).review?
            )
        else
          false
        end
    end

    def open_level_ids
      @open_level_ids ||=
        begin
          scope = @course.levels

          if access_locked_levels
            scope
          else
            scope.where(unlock_at: nil).or(
              @course.levels.where("unlock_at <= ?", Time.zone.now)
            )
          end.pluck(:id)
        end
    end
  end
end
