class UpdateScreeningDataOfFounders < ActiveRecord::Migration[5.1]
  def up
    Founder.where.not(screening_data: nil).each do |founder|
      updated_response = founder.screening_data['response'].map do |question, answer|
        {
          question: question,
          answer: answer
        }
      end
      founder.screening_data['response'] = updated_response
      founder.save!
    end
  end

  def down
    Founder.where.not(screening_data: nil).each do |founder|
      updated_response = founder.screening_data['response'].each_with_object({}) do |response, hash|
        hash[response['question']] = response['answer']
      end
      founder.screening_data['response'] = updated_response
      founder.save!
    end
  end
end
