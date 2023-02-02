FROM ruby

WORKDIR /service_confirming_code

COPY . .

RUN gem install bundler
RUN bundle install

CMD ["rake", "amqp_app"]
