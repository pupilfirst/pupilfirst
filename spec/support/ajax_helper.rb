module AjaxHelpers
  def wait_for_ajax
    counter = 0
    while page.evaluate_script('$.active').to_i > 0
      counter += 1
      sleep(0.1)
      fail 'AJAX request took longer than 5 seconds.' if counter >= 50
    end
  end
end
