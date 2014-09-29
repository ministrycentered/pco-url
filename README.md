# PCO::URL

Fetch the base URL for the current and other applications based on the current application environment.

## Usage

Uses `Rails.env` by default to determine the environment name.

Set `ENV["DEPLOY_ENV"]` to override this default.

```ruby
ENV["DEPLOY_ENV"] = "staging"

Rails.env
# => "production"

PCO::URL.accounts
# => "https://accounts-staging.planningcenteronline.com"
```

For individual apps, change an environment variable to specify the URL for a given app:

```ruby
ENV["ACCOUNTS_URL"] = "https://accounts-test1.planningcenteronline.com"

Rails.env
# => "staging"

PCO::URL.accounts
# => "https://accounts-test1.planningcenteronline.com"

PCO::URL.services
# => "https://services-staging.planningcenteronline.com"
```


You can also specify the path:


```ruby
PCO::URL.accounts("/test")
# => "https://accounts-test1.planningcenteronline.com/test"

PCO::URL.accounts("test")
# => "https://accounts-test1.planningcenteronline.com/test"

PCO::URL.accounts("test/", "working")
# => "https://accounts-test1.planningcenteronline.com/test/working"
```