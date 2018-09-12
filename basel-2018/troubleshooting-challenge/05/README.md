Wrong port
==========

Error
-----

```
Waiting for app to start...
Start unsuccessful
```

Hints
-----

1. What logs show?

    ```
    2018-09-12T16:25:16.21+0300 [API/0] OUT App instance exited with guid ceef1eb0-6578-48b4-9c6f-5afa7b7edfd0 payload: {"instance"=>"06d2a3cd-bea1-46ff-7dcb-e4b9", "index"=>0, "cell_id"=>"1d11bb91-6ebe-4b68-817d-688fe4152b01", "reason"=>"CRASHED", "exit_description"=>"Instance never healthy after 5s: Failed to make TCP connection to port 8080: connection refused", "crash_count"=>3, "crash_timestamp"=>1536758716205603428, "version"=>"59d19a0a-1f72-4660-943f-3878600f2c12"}
    ```

1. Look at application code. Does the aplication listen on the port from the OS "$PORT" variable?

Solution
--------

1. Change code of the app to use `$PORT` env variable

    From

    ```
    port := "8081";
    ```

    To

    ```
    port := os.Getenv("PORT");
    ```
