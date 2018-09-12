Out of memory
=============

Error

```
Start unsuccessful
```

Hints
-----

1. What does the logs say?

    ```
    2018-09-12T16:07:11.72+0300 [API/0] OUT App instance exited with guid 64e0dbf7-6a96-403a-807c-b4f018b5e5f7 payload: {"instance"=>"ed94b089-4343-4a8d-5428-0872", "index"=>0, "cell_id"=>"1d11bb91-6ebe-4b68-817d-688fe4152b01", "reason"=>"CRASHED", "exit_description"=>"APP/PROC/WEB: Exited with status 137 (out of memory)", "crash_count"=>3, "crash_timestamp"=>1536757631708073914, "version"=>"8d25d523-b14c-4ac9-8e08-998d33fedbe6"}
    ```

1. Check the memory limits for the application

Solution
--------

1. Increase memory limit in the manifest

    ```
    -  memory: 10M
    +  memory: 20M
    ```