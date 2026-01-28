namespace :event_engine do
  namespace :dead_letters do
    desc "List all dead-lettered events"
    task list: :environment do
      events = EventEngine::OutboxEvent.dead_lettered.ordered

      if events.empty?
        puts "No dead-lettered events found."
        next
      end

      puts "Dead-lettered events:"
      puts "-" * 80
      printf "%-10s %-30s %-10s %-20s\n", "ID", "Event Name", "Attempts", "Dead Lettered At"
      puts "-" * 80

      events.each do |event|
        printf "%-10s %-30s %-10s %-20s\n",
          event.id,
          event.event_name.truncate(30),
          event.attempts,
          event.dead_lettered_at.strftime("%Y-%m-%d %H:%M:%S")
      end

      puts "-" * 80
      puts "Total: #{events.count} event(s)"
    end
  end
end
