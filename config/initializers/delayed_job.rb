# Set priority for delayed job queues.
Delayed::Worker.queue_attributes = {
  high_priority: { priority: -10 },
  low_priority: { priority: 10 }
}
