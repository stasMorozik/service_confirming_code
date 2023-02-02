desc 'Run amqp application'
task :amqp_app do

  require 'pg'
  require 'bunny'
  require 'dotenv/load'
  require_relative 'apps/amqp/app'
  require_relative 'lib/adapters/postgreSQL/creating'
  require_relative 'lib/adapters/postgreSQL/getting'
  require_relative 'lib/adapters/postgreSQL/updating'
  require_relative 'lib/adapters/amqp/notifying'
  require_relative 'lib/core/use_cases/creating'
  require_relative 'lib/core/use_cases/confirming'

  Dotenv.load('.env')

  rb_connect = Bunny.new(
    :host => ENV["RB_HOST"],
    :vhost => ENV["RB_VHOST"],
    :user => ENV["RB_USER"],
    :password => ENV["RB_PASSWORD"]
  )
  rb_connect.start

  channel = rb_connect.create_channel
  channel.confirm_select

  puts ENV["RB_HOST"]

  pg_connect = PG.connect(
    :dbname   => ENV["PG_NAME"],
    :host     => ENV["PG_HOST"],
    :port     => ENV["PG_PORT"],
    :user     => ENV["PG_USER"],
    :password => ENV["PG_PASSWORD"]
  )

  logging_queue  = channel.queue(ENV["LOGGING_QUEUE"])
  creating_queue  = channel.queue(ENV["CREATING_QUEUE"])
  confirming_queue  = channel.queue(ENV["CONFIRMING_QUEUE"])
  response_queue = channel.queue(ENV["RESPONSE_QUEUE"])
  notifying_queue = channel.queue(ENV["NOTIFYING_QUEUE"])

  creating_adapter = Adapters::PostgreSQL::Creating.new(pg_connect)
  getting_adapter = Adapters::PostgreSQL::Getting.new(pg_connect)
  updating_adapter = Adapters::PostgreSQL::Updating.new(pg_connect)

  notifying_adapter = Adapters::Amqp::Notifying.new(notifying_queue)

  creating_use_case = Core::UseCases::Creating.new(
    getting_adapter,
    creating_adapter,
    notifying_adapter
  )

  confirming_use_case = Core::UseCases::Confirming.new(
    getting_adapter,
    updating_adapter
  )

  amqp_app = Apps::Amqp::App.new(
    creating_use_case,
    confirming_use_case,
    channel,
    creating_queue,
    confirming_queue,
    response_queue,
    logging_queue,
    ENV["ID_APPLICATION"]
  )

  amqp_app.run
end
