# Todoable

[![Coverage Status](https://coveralls.io/repos/github/sbauch/todoable-sb/badge.svg?branch=coverage-style-docs)](https://coveralls.io/github/sbauch/todoable-sb?branch=coverage-style-docs)
[![Maintainability](https://api.codeclimate.com/v1/badges/f6bc5108df42ab0df74c/maintainability)](https://codeclimate.com/github/sbauch/todoable-sb/maintainability)

## Assignment Writeup

This was a good sized project for this purpose and I enjoyed it! Although this gem will obviously not be released, I made an effort to make this a really professional codebase with documentation, specs, style rules, and codeclimate integration.

I also put together a [small demo app](https://sb-todoable-demo.herokuapp.com/) ([source](https://github.com/sbauch/todoable-sb-demo)) that utilizes the gem. I initially did this to sort of go the extra mile and show my front end skills for this full stack position, but it ended up paying dividends in the design of the gem.

I've been writing a lot of Swift lately, and while the type checking in Swift can [sometimes be annoying](https://twitter.com/sammybauch/status/919956095749316614), coming back to Ruby world things felt a little error prone. So initially designed the gem's API to expect initialized objects.

When I built the demo app to actually use the gem, I decided that this notion of passing around objects, while less error prone, would be frustrating to the developer, so I redesigned the API to expect IDs as strings.

Another sticking point throughout the exercise was authentication. This really can be a lesson in why oAuth exists. I felt uncomfortable having the username and password, particularly keeping them around in memory in order to reauthenticate. I would not recommend using the Client object as a global variable with automatic refreshing. Instead, I would expect developers to authenticate a client each time she wanted to make an API call. But the spec asked for refreshing against a 20 minute expiry, so the gem supports it.

### Documentation issues

I found a couple issues in the docs, maybe they are intentional:
- Location header was not being returned for 201 created statuses (fixed)
- The example payload for GET '/lists' shows a namespaced `list` at the top of the json. This does not exist in prod.
- The example payload for GET '/lists' is invalid json (missing a `:` after the `items` key)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'todoable-sb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install todoable-sb

## Usage

This gem wraps the (fake) Todoable API. You must acquire a username and password from Todoable to use with this gem.

### Client Initialization

You must initialize a client in order to make API calls. It is recommended that you initialize a client each time you want to make a call rather than maintaining a reference to the client globally.

When you initialize a client, you must then authenticate it in order to receive a token to be used for subsequent requests.

The simplest way to this is to use `Todoable::Client.build`:

```ruby
  client = Todoable::Client.build(username: "username", password: "password")
```

You now have a client and can make API calls on behalf of that user.

For example, to get all of the user's lists:

```ruby
  client.lists()
  # => [ <Todoable::List @name="Urgent Tasks", @id="uuid" @items=[]>,
  #      <Todoable::List @name="Regular Tasks", @id="uuid" @items=[]>
  #    ]
```

## Documentation
Docs can be generated via [yard](https://github.com/lsegal/yard#installing).

They are also included in the `docs/` directory.
(sb note: normally this would be gitignored and docs on rdoc)
