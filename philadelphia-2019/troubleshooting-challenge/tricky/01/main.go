package main

import (
	"fmt"
	"net/http"
	"os"
)

func serve(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<head><style type='text/css'> body {font-size: 56px;font-weight: bold; background-color: #f75151; text-align: center;}</style></head>")
	fmt.Fprintf(w, "<body>CONGRATULATIONS<br>you just completed tricky task #01</body>");
}

func main() {
	http.HandleFunc("/", serve);

	var port string;
	os.Getpid();

	port = "80"

	http.ListenAndServe(":" + port, nil);
}
