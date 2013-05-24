# punchtab

Ruby wrapper for [PunchTab API](http://www.punchtab.com/developer-docs), the world's first instant loyalty platform.

## Installation

```
gem install punchtab
```

## Prerequisites

1. Get a developer account at [PunchTab](http://www.punchtab.com).
2. Make sure your PunchTab account is enabled for SSO authentication. Do so, by going to the developer account page,
and checking the 'Single Sign On (SSO)' checkbox.

![Enable SSO authentication for PunchTab account](punchtab-enable-sso.png "Enable SSO authentication for PunchTab account")

## Getting Started

### Authenticate using Single Sign On (SSO)

```ruby
# authenticate with PunchTab
client = Punchtab::Client.new(
  :client_id  => 'your client_id',
  :access_key => 'your access_key',
  :secret_key => 'your secret_key',
  :domain     => 'www.mydomain.com',
  :user_info => {
    :first_name => 'your first_name',
    :last_name  => 'your last_name',
    :email      => 'me@mydomain.com'}
)
# if authentication is successful, you should get an access token back
puts "Access Token: #{client.access_token}"

# if authentication fails, an exception is thrown

```
> Note: You can get all of the above values from your Punchtab [developer account page](https://www.punchtab.com/account/).

### Authentication

```ruby
# check authentication status
client.status
=> {"status"=>"connected",
 "authResponse"=>
  {"userID"=>"111111_1111",
   "uid"=>"111111",
   "accessToken"=>"ed17a5f0ad9e52db0576f39602083dc7"}}
```

```ruby
# logout
client.logout
=> {"status"=>"disconnected"}
```

### Activity

```ruby
# get all activities
client.get_activity
=> [{"domain"=>"www.webintellix.com",
  "display_name"=>"Webintellix",
  "name"=>"comment",
  "referrer"=>"http://www.webintellix.com",
  "points"=>600,
  "date_created"=>"2013-05-23 06:37:54",
  "_id"=>"xxxxxxxxxxxxxxxxxx",
  "publisher_id"=>2222},
 {"domain"=>"www.webintellix.com",
  "display_name"=>"Webintellix",
  "name"=>"comment",
  "referrer"=>"http://www.webintellix.com",
  "points"=>600,
  "date_created"=>"2013-05-22 04:50:53",
  "_id"=>"xxxxxxxxxxxxxxxxxx",
  "publisher_id"=>2222},
 {"domain"=>"www.webintellix.com",
  "display_name"=>"Webintellix",
  "name"=>"plusone",
  "referrer"=>"http://www.webintellix.com",
  "points"=>500,
  "date_created"=>"2013-05-22 03:36:13",
  "_id"=>"xxxxxxxxxxxxxxxxxx",
  "publisher_id"=>2222},
 {"domain"=>"www.webintellix.com",
  "display_name"=>"Webintellix",
  "name"=>"like",
  "referrer"=>"http://www.webintellix.com",
  "points"=>400,
  "date_created"=>"2013-05-22 02:58:27",
  "_id"=>"xxxxxxxxxxxxxxxxxx",
  "publisher_id"=>2222}]
```

```ruby
# get 2 activities
client.get_activity(:limit => 2)
=> [{"domain"=>"www.webintellix.com",
  "display_name"=>"Webintellix",
  "name"=>"comment",
  "referrer"=>"http://www.webintellix.com",
  "points"=>600,
  "date_created"=>"2013-05-22 04:50:53",
  "_id"=>"xxxxxxxxxxxxxxxxxx",
  "publisher_id"=>2222},
 {"domain"=>"www.webintellix.com",
  "display_name"=>"Webintellix",
  "name"=>"plusone",
  "referrer"=>"http://www.webintellix.com",
  "points"=>500,
  "date_created"=>"2013-05-22 03:36:13",
  "_id"=>"xxxxxxxxxxxxxxxxxx",
  "publisher_id"=>2222}]
```

```ruby
# get only 'like' activities
client.get_activity(:activity_name => :like)
=> [{"domain"=>"www.webintellix.com",
  "display_name"=>"Webintellix",
  "name"=>"like",
  "referrer"=>"http://www.webintellix.com",
  "points"=>400,
  "date_created"=>"2013-05-22 02:58:27",
  "_id"=>"xxxxxxxxxxxxxxxxxx",
  "publisher_id"=>2222}]
```

```ruby
# create a new activity, and assign it relevant 'points'
client.create_activity(:comment, 600)
=> [{"domain"=>"www.webintellix.com",
  "user_id"=>111111,
  "name"=>"comment",
  "referrer"=>"http://www.webintellix.com",
  "points"=>600,
  "date_created"=>"2013-05-22 03:54:42",
  "_id"=>"xxxxxxxxxxxxxxxxxx",
  "publisher_id"=>2222,
  "display_name"=>"Webintellix"}]
```

```ruby
# redeem offer for an activity using a 'reward_id'
client.redeem_activity_offer(123)
```

### User

```ruby
# get details about the current user
c.get_user
=> {"first_name"=>"Rupak",
 "last_name"=>"Ganguly",
 "user_id"=>111111,
 "name"=>"Rupak Ganguly",
 "timeline"=>false,
 "badge_count"=>0,
 "foursquare"=>false,
 "optedOut"=>false,
 "redemptions"=>0,
 "new_lb"=>1,
 "redeemable_points"=>3200,
 "total_points_earned"=>3200,
 "avatar"=>
  "https://s3.amazonaws.com/punchtab-static/img/default_facebook_avatar.jpg"}
```

### Reward

```ruby
# get all the rewards
c.get_reward
=> [{"merchantname"=>"Target",
  "image"=>{},
  "label"=>"$5 Target Gift Card",
  "points"=>15000,
  "redeemable"=>false,
  "shipping_address"=>false,
  "id"=>33333,
  "reward_id"=>33333},
 {"merchantname"=>"Starbucks",
  "image"=>{},
  "label"=>"$5 Starbucks Card",
  "points"=>10000,
  "redeemable"=>false,
  "shipping_address"=>false,
  "id"=>44444,
  "reward_id"=>44444}]
```

```
# get specified number of rewards
c.get_reward(:limit => 1)
=> [{"merchantname"=>"Target",
  "image"=>{},
  "label"=>"$5 Target Gift Card",
  "points"=>15000,
  "redeemable"=>false,
  "shipping_address"=>false,
  "id"=>33333,
  "reward_id"=>33333}]
```

### Leaderboard

```ruby
# get the current user's leaderboard
client.get_leaderboard
=> [{"username"=>"111111_1111",
  "recent_activity"=>
   {"domain"=>"www.webintellix.com",
    "display_name"=>"Webintellix",
    "name"=>"comment",
    "referrer"=>"",
    "points"=>600,
    "date_created"=>"2013-05-23 06:37:54.296496",
    "_id"=>"",
    "publisher_id"=>2222},
  "name"=>"Rupak Ganguly",
  "self"=>true,
  "rank"=>1,
  "points"=>3200,
  "avatar"=>
   "https://s3.amazonaws.com/punchtab-static/img/default_facebook_avatar.jpg",
  "user_id"=>111111}]
```

```ruby
# get the specified user's leaderboard
c.get_leaderboard(111111)
=> [{"username"=>"111111_1111",
  "recent_activity"=>
   {"domain"=>"www.webintellix.com",
    "display_name"=>"Webintellix",
    "name"=>"comment",
    "referrer"=>"",
    "points"=>600,
    "date_created"=>"2013-05-23 06:37:54.296496",
    "_id"=>"",
    "publisher_id"=>2222},
  "name"=>"Rupak Ganguly",
  "self"=>true,
  "rank"=>1,
  "points"=>3200,
  "avatar"=>
   "https://s3.amazonaws.com/punchtab-static/img/default_facebook_avatar.jpg",
  "user_id"=>111111}]
```

```ruby
# get leaderboard for current user with optional parameters
c.get_leaderboard(:days => 10, :limit => 3, :page => 1)
=> [{"username"=>"111111_1111",
  "user_id"=>111111,
  "name"=>"Rupak Ganguly",
  "self"=>true,
  "rank"=>1,
  "points"=>3200,
  "avatar"=>
   "https://s3.amazonaws.com/punchtab-static/img/default_facebook_avatar.jpg",
  "recent_activity"=>
   {"domain"=>"www.webintellix.com",
    "display_name"=>"Webintellix",
    "name"=>"comment",
    "referrer"=>"http://www.webintellix.com",
    "points"=>600,
    "date_created"=>"2013-05-23 06:37:54",
    "_id"=>"xxxxxxxxxxxxxxxxxxx",
    "publisher_id"=>2222}}]
```

```ruby
# get leaderboard for specified user's leaderboard, with optional parameters
c.get_leaderboard(:with => 2173196, :days => 10, :limit => 3, :page => 1)
=> [{"username"=>"111111_1111",
  "user_id"=>111111,
  "name"=>"Rupak Ganguly",
  "self"=>true,
  "rank"=>1,
  "points"=>3200,
  "avatar"=>
   "https://s3.amazonaws.com/punchtab-static/img/default_facebook_avatar.jpg",
  "recent_activity"=>
   {"domain"=>"www.webintellix.com",
    "display_name"=>"Webintellix",
    "name"=>"comment",
    "referrer"=>"http://www.webintellix.com",
    "points"=>600,
    "date_created"=>"2013-05-23 06:37:54",
    "_id"=>"xxxxxxxxxxxxxxxxxxx",
    "publisher_id"=>2222}}]
```

## Roadmap

* Add tests

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but
  bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2013 [Rupak Ganguly](http://rails.webintellix.com). See [LICENSE](https://github.com/rupakg/punchtab/blob/master/LICENSE) for details.
