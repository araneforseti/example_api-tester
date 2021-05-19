FROM ruby:2.6

# Uncomment the following line if a Gemfile.lock is used
# RUN bundle config --global frozen 1

WORKDIR /usr/src/app
EXPOSE 4567

COPY . /usr/src/app
RUN gem install bundler:2.2.17
RUN bundle install

CMD ruby janky_api.rb -o 0.0.0.0
