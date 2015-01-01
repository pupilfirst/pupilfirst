module MentorMeetingsHelper
	def durations_list
		{
			"15 Mins" => MentorMeeting::DURATION_QUARTER_HOUR,
			"30 Mins" => MentorMeeting::DURATION_HALF_HOUR,
			"One hour" => MentorMeeting::DURATION_HOUR
		}
	end

	def time_list
		[Mentor::AVAILABILITY_TIME_MORNING, Mentor::AVAILABILITY_TIME_MIDDAY, Mentor::AVAILABILITY_TIME_AFTERNOON, Mentor::AVAILABILITY_TIME_EVENING].inject({}) do |result, element|
			result[element.capitalize] = element
			result
		end		
	end
end
