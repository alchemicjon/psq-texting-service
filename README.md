# psq-texting-service
An API that accepts a text message from a client, and sends that text message to SMS providers. It also accepts a callback with the message's status.

## Primary Dependencies and versions
- Ruby: 3.2.2
- Ruby on Rails: 7.0.5
- Rubygems: 3.4.14
- Bundler: 2.4.14
- PostgreSQL: 14
- Ngrok: 3.3.1

## Setup

### Prerequisites
There is some initial setup required to run this API locally. You'll need to:
- Install Ruby
- Have the `bundler` gem installed
- Have a local postgresql install running
- Have Ngrok installed
- Clone the repo

If you don't have any of that set up yet and happen to be on a Mac, you may find this [page in the wiki](https://github.com/alchemicjon/psq-texting-service/wiki/Detailed-setup-instructions:-Mac) helpful.

### Creating your database user
You need to create a user with a password for this app to run - remember the password, you'll need it for the setup script.
```
createuser -P -d psq_texting_service
# Enter a password at the prompt
```

### Start ngrok
You need to start ngrok to get your forwarding address - this will be used during the setup script as well.
```
ngrok http 3000
```

### Run the setup script
This script will make sure you have all the gems you need, set up the databases and seed data, and then add your database password and forwarding url to `.env` so that it's available to the app.
```
bin/setup
# Enter your password and url when prompted
```

## Running the app
Running the api is pretty simple once the setup is out of the way:
```
bin/rails server
```

Now you can create messages using curl (or whatever tool you prefer):
```
curl -X POST -H "Content-Type: application/json" \
    -d '{"number": "412 255 2626", "body": "hello world"}' \
    localhost:3000/messages
```

Note that you can use localhost here instead of the forwarding URL - I found that much simpler for running this locally.

## Running tests
I used Minitest to create my test suite. You can run all the tests using:
```
bin/rails test
```
I also used Rubocop as my linter. You can run that using:
```
rubocop
```

## Implementation Notes
The overall structure of the API is relatively simple, but there are a few things I think are worth highlighting here.
### `SmsService`
I created a Plain Old Ruby Object (PORO) to handle the majority of the business logic of the application. I personally like using service objects like this to encapsulate business logic, because the business logic is now reusable and it keeps the models and controllers relatively thin. If this were a larger application, I would strongly consider making a `BaseService` class to encapsulate commonalities across other services, and then have other service objects inherit from that service. 

#### `SmsService`'s API
##### `#call(message)`
This method is the entrypoint into using an instance of this class. Returns true if a request to an SMS Provider was successfull, and returns false if it was not. Accepts a `Message` to send as an argument, and will update the `Message` with the `message_id` returned from one of the providers so it can be referred to later during the callback.
##### `#success?`
Returns true if the service's `#call` method was successful, and false if it was not.
##### `#failure?`
The opposite of `#success?`.

#### Weighting calls to different providers
The `#select_provider` method of `SmsProvider` has the implementation picking which provider to send the request to. My approach here was to give each provider a `weight` attribute, and use Ruby's `Random` class to pick between the two. Weights are floats that represent a percentage. I got a random float 

I decided to create a `weight` attribute on the `SmsProvider` model to represent the percentage of the time a provider should be picked as floating point number. With the goal of randomly selecting one of the two providers based on their weight value, I created an array of the providers and accumulated the total weight so far. I then generated a random float between 0 and the total sum of all `weight`s, and used the hightest accumulated weight that was less than the random number. Sound confusing? I think so too, so an example may be warrented here.

Let's say we have two providers (a and b) with respective weight values of 0.3 and 0.7. Constructing the array might look a little like this:
```
ranges = [[0.3, a], [1.0, b]]
```
Since provider b has a weight of 0.7, the accumulated weight so far because 1.0. You can add as many providers as you want - if we had 3 providers (a, b, and c) with weights of 0.2, 0.5, and 0.3 respectively, it could look something like...
```
ranges = [[0.2, a], [0.7, b], [1.0, c]]
```
Every entry for a provider has a weight value that is the total of it's weight plus all previous weights.

Once we have that array, we can generate a random float between 0 and the max (in this case 1.0) to determine which one to pick. We take the value in the array with the hightest accumulated weight that is still lower than the random number to do that. For example:
```
random = Random.new.rand(1.0)
# let's say that equals 0.85
```
Provider c is the one with the highest accumulated weight (1.0) that's still less than the random number (0.85), so it gets selected. Provider c had a 30% chance of getting selected, and in this implementation that's represented by the fact that it's accumulated weight (1.0) minus the previous weight (0.7) is 0.3.

#### Retries
If the provider isn't available, `SmsService` will retry using the remaining providers it knows about. I hang on to the id of all providers attempted in the `@provider_attempts` array. On each try, I select a provider randomly (based on weight, see above) that is not in the list of attempts so far. Since there are only two providers here, it's fairly straightforward - on first attempt, there are no attempted providers yet, so it selects from the entire list and saves the id of the one it tried. On the second attempt, it excludes the first provider it tried, which naturally means the second one is picked. However, you could add any number of providers to the list and the algorithm would still work, and would still use the appropriate weighted distibution to select the next provider. The service will retry until either 1) there's a successful response or 2) there are no providers left to try.

### Phonelib usage
I used the `phonelib` gem to parse and standardize phone numbers that get sent to the API. A side effect of this is that all phone numbers saved in the database start with "+1" (assuming it's a US number), and as such even if a phone number starts with 3 or 4 when passed to the API, it won't trigger the "invalid" test case from the provider because it actually starts with a "+1".

## Assumptions
- This service currently only works for US numbers.
