## net/http

Go's standard `net/http` package provides the tools for making HTTP requests and handling responses. 


The `http.Client` type, part of this package, sends HTTP requests and lets you configure how they are sent.





# Sending and Receiving JSON

JSON travels over HTTP as bytes. When sending JSON, you encode a Go value into JSON bytes. When receiving JSON, you decode those bytes into a Go type.
- Receiving JSON → decode bytes into a Go type
- Sending JSON → encode Go value into bytes

The `encoding/json` package provides functions to parse JSON data into Go objects (unmarshalling) and convert Go objects into JSON data (marshalling).

## Decoding JSON

### Struct

When we receive JSON data in the body of an HTTP response, it comes as a stream of bytes. In Go, it's common to decode this JSON data into a struct (or a slice of structs). To do so, we typically define the struct's fields and their types beforehand, matching the structure of the expected JSON response.

Expected JSON response:
```json
[
    {
        "id": 1,
        "name": "Alice",
        "email": "alice@example.com"
    }
]
```

Structure to decode into:
```go
// The standard encoding/json package uses tags to map JSON fields to struct fields
type User struct {
    Id   int    `json:"id"`
    Name string `json:"name"`
    Email string `json:"email"`
}
```

After receiving the response, we can decode it into a slice of `User`s with the "address of" operator `&`:
```go
var users []User
decoder := json.NewDecoder(res.Body)    // creates a streaming JSON reader from the response body
err := decoder.Decode(&users)           // decodes into users
if err != nil {
    fmt.Println("error decoding response body")
    return    
}
```

If no error occurs, we can use the slice of items in our program:
```go
for _, user := range users {
    fmt.Printf("User – id: %v, Name: %v, Email: %v\n", user.Id, user.Name, user.Email)
    // User – id: 1, Name: Alice, Email: alice@example.com
}
```

### Map

Sometimes you have to deal with JSON data of unknown or varying structure in Go. In those instances `map[string]interface{}` offers a flexible way to handle it without predefined structs.

A JSON object is a key-value pair, where the key is a string and the value can be any JSON type. `map[string]interface{}` is a map where the key is a string and the value can be any Go type.

```go
var data map[string]interface{}
jsonString := `{"name": "Alice", "age": 30, "address": {"city": "Wonderland"}}`
json.Unmarshal([]byte(jsonString), &data)

fmt.Println(data["name"])  // Output: Alice
fmt.Println(data["address"].(map[string]interface{})["city"])  // Output: Wonderland
```

Rule of thumb: Use structs for known data models, such as API responses representing users or orders. Structs provide type safety, compile-time checks, and clearer code. Use maps for dynamic data where flexibility matters more than a predefined structure.

### json.Unmarshal vs json.Decoder

We can decode JSON bytes into a Go object using `json.Unmarshal` or a `json.Decoder`. The former is used when the JSON is already available as `[]byte`, while the latter reads JSON directly from a response body, since `resp.Body` implements `io.Reader` and provides a stream of bytes.

Using `json.Unmarshal`:

```go
import (
	"io"
    "fmt"
	"net/http"
    "encoding/json"
)

// Expected JSON response: [{"id": 1, "name": "Alice"}]
type User struct {
    ID   int    `json:"id"`
    Name string `json:"name"`
}

func getUsers() ([]User, error) {
	res, err := http.Get("https://api.jello.com/users")     
	if err != nil {
		return nil, fmt.Errorf("error making request: %w", err)
	}
    defer res.Body.Close()                  // close response body - not doing so can cause memory issues

	data, err := io.ReadAll(res.Body)       // reads the response body into a slice of bytes []byte 
	if err != nil {
		return nil, fmt.Errorf("error reading response: %w", err)
	}

    var users []User
    err := json.Unmarshal(data, &users)      // converts bytes to a slice of User structs
    if err != nil {
        return nil, fmt.Errorf("error decoding data: %w", err)
    }
	return users, nil
}
```

Using `json.Decoder`:

```go
import (
    "fmt"
	"net/http"
    "encoding/json"
)

// Expected JSON response: [{"id": 1, "name": "Alice"}]
type User struct {
    ID   int    `json:"id"`
    Name string `json:"name"`
}

func getUsers() ([]User, error) {
	res, err := http.Get("https://api.jello.com/users")     
	if err != nil {
		return nil, fmt.Errorf("error making request: %w", err)
	}
    defer res.Body.Close()                  

    var users []User
    decoder := json.NewDecoder(res.Body)    // res.Body implements io.Reader
    err := decoder.Decode(&users)           
    if err != nil {
        return nil, fmt.Errorf("error decoding data: %w", err)
    }
	return users, nil
}
```

## Encoding JSON

If there is a way to unmarshal JSON data, there must be a way to marshal it as well. The `json.Marshal` function converts a Go struct into a slice of bytes representing JSON data.

```go
type User struct {
    Id   int    `json:"id"`
    Name string `json:"name"`
}

user := User{
    Id:     1,
    Name:   "Alice",
}

data, err := json.Marshal(user)
if err != nil {
	log.Fatal(err)
}
fmt.Println(string(data))
// {"id":1,"name":"Alice"}
```

# URIs

## Deconstructing URLs

URLs pack multiple pieces of distinct communication into one compact string. URL Parsing breaks this string into structured components (scheme, host, path, query parameters, fragment).

The `net/url` package is part of Go's standard library. You can instantiate a [URL struct](https://pkg.go.dev/net/url#URL) using `url.Parse` 

```go
parsedURL, err := url.Parse("https://homestarrunner.com/toons")
if err != nil {
	fmt.Println("error parsing url:", err)it wou
	return
}
```

and then you can extract components:

```go
parsedURL.Hostname()
// homestarrunner.com

parsedURL.Scheme
// https

parsedURL.Path
// /toons
```

Extracting components like the `Hostname`, `Scheme`, or `User` credentials allows you to sanitize input, validate trusted redirect domains, or ensure traffic uses secure protocols (`https` instead of `http`). For a more structured approach, we can wrap this in a function which parses URLs into a struct:

```go
type ParsedURL struct {
	protocol string
	username string
	password string
	hostname string
	port     string
	pathname string
	search   string
	hash     string
}

func newParsedURL(urlString string) ParsedURL {
	parsedUrl, err := url.Parse(urlString)
	if err != nil {
		return ParsedURL{}
	}
	
	password, _ := parsedUrl.User.Password()    //  returns two values: the password if set and whether it was set
	return ParsedURL{
		protocol: parsedUrl.Scheme,
		username: parsedUrl.User.Username(),
		password: password,
		hostname: parsedUrl.Hostname(),
		port:     parsedUrl.Port(),
		pathname: parsedUrl.Path,
		search:   parsedUrl.RawQuery,
		hash:     parsedUrl.Fragment,
	}
}
```

# Headers

An [HTTP header](https://developer.mozilla.org/en-US/docs/Glossary/HTTP_header) allows clients and servers to pass additional information with each request or response. Headers are just case-insensitive key-value pairs that pass additional metadata about the request or response.

HTTP requests from a web browser automatically carry with them many headers, including but not limited to:

- The type of client (e.g. Google Chrome)
- The operating system (e.g. Windows)
- The preferred language (e.g. US English)

As developers, we can also define custom headers in each request.

Headers are useful for several reasons from design to security, but most often headers are used for metadata about the request or response itself. [Authentication](https://auth0.com/intro-to-iam/what-is-authentication) is a common use case for headers. For example, when making an API request, you may need to include an authentication token to prove your identity. This information is not the request itself, but additional information that tells the server who is making the request and whether they are authorized to access the resource.

# Methods

## Making a GET Request in Go

There are two basic ways to make a Get request in Go.

1. The simple but less powerful way: `http.Get`
2. The verbose but more powerful way: `http.Client`, `http.NewRequest`, and `http.Client.Do`

If all you need to do is make a simple GET request to a URL, `http.Get` will work:

```go
resp, err := http.Get("https://jsonplaceholder.typicode.com/users")
```

If you need to customize things like headers, cookies, or timeouts, you'll want to create a custom `http.Client`, and `http.NewRequest`, then use the client's `Do` method to execute it.

```go
client := &http.Client{
	Timeout: time.Second * 10,
}

req, err := http.NewRequest("GET", "https://jsonplaceholder.typicode.com/users", nil)
if err != nil {
	log.Fatal(err)
}

resp, err := client.Do(req)
```