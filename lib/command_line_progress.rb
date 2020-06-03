class CommandLineProgress
  def initialize(max)
    @max = max
    @current = 0
    @percentage = 0

    puts "Starting processing of #{@max} entries..." if @max.positive? # rubocop:disable Rails/Output
  end

  def current_string_length
    @current_string_length ||= @max.to_s.length
  end

  def tick
    @current += 1
    changed = compute_percentage
    inform_progress if changed
  end

  def compute_percentage
    new_percentage = (@current / @max.to_f) * 100.0

    if new_percentage - @percentage >= 10.0
      @percentage += 10
      true
    else
      false
    end
  end

  def inform_progress
    if @percentage.to_i == 100
      puts 'Processing complete!' # rubocop:disable Rails/Output
    else
      puts "Progress: #{@percentage}% [ #{@current.to_s.rjust(current_string_length, ' ')}/#{@max} ]" # rubocop:disable Rails/Output
    end
  end
end
