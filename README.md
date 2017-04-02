# sgShowtimesApi

Scrapes Singapore showtimes

## Deployment
1. Install ruby
2. Install the `bundler` gem and run `bundle install --production`
3. Add the scraper and maintenance task to cron using `bundle exec whenever -w`

### Database
1. Install `postgresql` and create a new database according to `config/database.yml`. Follow the production section for configuration
2. Run `RACK_ENV='production' bundle exec rake db:setup` to setup and seed the database

Lastly, run the server in production using
`RACK_ENV='production' ruby server.rb`

[API Documentation](docs/api-ref.md)
