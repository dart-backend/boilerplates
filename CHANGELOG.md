# Change Log

## 1.1.0

### New in 1.1.0

* The `basic_kelicap` template: an Angel3 API with a Kelicap web client, which calls it with `angel3_client` and shares its model classes. Its client depends on Kelicap 1.1.4.
* The development and production servers of every template listen on the `host` and `port` of `config/`, which can be read from the environment (`port: $PORT`). The production server's `-a` and `-p` override them, as the `Containerfile`s do, so containers still listen on `0.0.0.0:3000`.

### Fixes in 1.1.0

* **Kelicap:** The greetings form keeps what the user typed while a greeting was being added, and the text of a greeting that could not be added.
* **Kelicap:** Submitting the greetings form again while a greeting is being added no longer adds it twice: the Add button is disabled until the server answers.
* **Kelicap:** The greetings page says "The server could not be reached." only when the request did not reach it. A reply it cannot read shows the server's error, and an error of the app shows "Something went wrong." and is reported in the browser's console.
* **Kelicap:** The README links to the [Kelicap documentation](https://dukefirehawk.gitbook.io/kelicap-docs) site, where it linked to its GitHub repository

## 1.0.0

* Initial version
