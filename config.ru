# frozen_string_literal: true

require './app'
require 'sinatra'
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Exporter

run Sinatra::Application
