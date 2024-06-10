#!/usr/bin/env ruby

# frozen_string_literal: true

require './retiready'
require 'prometheus/client'
require 'concurrent'

$stdout.sync = true

def retiready_metrics(gauge)
  retiready = Retiready.new(
    ENV['RETIREADY_USERNAME'],
    ENV['RETIREADY_PASSWORD'],
    ENV['RETIREADY_PLANS'],
    ENV['TWO_CAPATCH_KEY']
  )
  metrics = retiready.metrics

  metrics.each do |metric|
    puts metric
    gauge.set(metric[:value], labels: { plan: metric[:name] })
  end
end

prometheus = Prometheus::Client.registry

gauge = Prometheus::Client::Gauge.new(:retiready, docstring: 'Aegon Retiready Metrics', labels: [:plan])

retiready_metrics(gauge)

prometheus.register(gauge)

task = Concurrent::TimerTask.new(execution_interval: 600) do
  retiready_metrics(gauge)
rescue StandardError => e
  puts e.full_message
end
task.execute
