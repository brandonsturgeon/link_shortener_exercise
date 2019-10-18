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
If the given `long_url` is malfornmed in any way, an error will be returned in this format:
```js
{"error":"Invalid URL"}
```

Continuing with our example, a `GET` to `/sR5mLQ` will return a `301` redirect to `https://www.google.com/test`
If an invalid path is given, the tool will return a `404`

A `GET` to `/sR5mLQ/analytics` will yield a JSON response in this format:
```js
{"response":[{"time":"2019-10-17 18:19:16 -0700","referer":null,"user_agent":"curl/7.54.0"},{"time":"2019-10-17 18:19:17 -0700","referer":null,"user_agent":"curl/7.54.0"},{"time":"2019-10-17 18:19:19 -0700","referer":null,"user_agent":"curl/7.54.0"}]}
```

If no analytics have been recorded for the given path, an error will be returned in this format:
```js
{"error":"Invalid URL"}
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
