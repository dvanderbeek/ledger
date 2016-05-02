class Action
  class CreatePaymentSchedule < ::Action
    def trigger(inputs)
      puts description
    end

    def description
      'Create a new schedule in Scheduler'
    end
  end
end
