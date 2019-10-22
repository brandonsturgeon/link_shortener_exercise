# link_shortener_exercise
It shortens links. Shortens them /real/ good.


## Running the app
**Requirements:**
- OSX or Linux should work fine, special steps would need to be taken on Windows
- `ruby` executable in PATH (I used 2.6.3, I can't promise any other version will work)
- `bundle` executable in PATH

**Running:**
```bash
/bin/bash path/to/start_server.sh
```
Or, if you're in the project dir and have met all of the requirements:
```bash
./start_server.sh
```


## Usage
A `POST` to `/short_link` with a json-compliant body including a `long_url` key (value should be a  FQDN, protocol optional) will yield a response similar to this:
```js
{"long_url":"www.google.com/test","short_url":"http://localhost:8080/sR5mLQ"}
```
If the given `long_url` is malfornmed in any way, an error will be returned in this format as a `400` error:
```js
{"error":"Invalid URL"}
```

Continuing with our example, a `GET` to `/sR5mLQ` will return a `301` redirect to `https://www.google.com/test`
If an invalid path is given, the tool will return a `404`

A `GET` to `/sR5mLQ/analytics` will yield a JSON response in this format:
```js
{"response":[{"time":"2019-10-17 18:19:16 -0700","referer":null,"user_agent":"curl/7.54.0"},{"time":"2019-10-17 18:19:17 -0700","referer":null,"user_agent":"curl/7.54.0"},{"time":"2019-10-17 18:19:19 -0700","referer":null,"user_agent":"curl/7.54.0"}],"total_views":3}
```

## Notes
### Cached Link
The tool will return the same shortened URL when given an already-shortened link, but it's important to note that the URL would need to be the _exact same_.
For example,
```
www.google.com
```
Would be considered different than
```
google.com
```

The same URL with added or different parameters will be considered a separate URL.
For example,
```
www.google.com/test?param1=foo
```
Would be considered different than
```
www.google.com/test?param2=bar
```

### Redirection protocol
All redirects are done using `https://`, even if the shortened link had `http://`


## Infinity, and beyond.

### Persistent Storage plans
At first I struggled a bit with what persistent storage solution would fit best in the project.
I had considered Redis' RDB persistance solution because of it speed and simplicity, plus the simple key/value was an appealing option for our situation, because at its simplest form, it maps one URL to another.
However, after implementing the analytics and building a better vision for the product, it became clear that ActiveRecord was the way to go

Used correctly, it could be pretty dang quick. Any speed issues could be fixed up by throwing a cache or three in front of it.
It gives us the freedom to expand the Analytics portion in whatever direction we'd like, and allows for more information to be tacked on to the URL (creator, expiration date, other relationships, etc.)

So, using AR, we'd have a `ShortenedURL` table that paired the shortened path (not the entire link, just the path after the `/`) and the long (the redirect) URL. We could even look into hashing the path in some way to simplify the field.
We'd index the shortened path (could potentially even make it the primary key, but that would take some toying) because we're only doing a long -> short lookup once during the create action, where speed isn't a concern, but we'd index `short`.

Now, `Analytics`. I think we'd keep it simple, and say that `ShortenedURL` `has_many` `Visits`. A `Visit` contains all relevant information about the visit. Origin, headers, etc.



Going through all of this makes me think of the cool analytics one could provide to link owners. A full frontend would be really fun to make for this.

