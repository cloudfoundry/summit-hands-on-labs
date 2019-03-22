package main

import (
	"fmt"
	"net/http"
	"os"
)

func serve(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<head><style type='text/css'> body {font-size: 56px;font-weight: bold; background-color: #f75151; text-align: center;}</style></head>")
	fmt.Fprintf(w, "<body>CONGRATULATIONS<br>you just completed tricky task #02</body>");
}

func main() {
	http.HandleFunc("/", serve);

	var port string;

	port = os.Getenv("PORT");
	if len(port) == 0 {
		port = "8080"
	}

	env := os.Getenv("SOMEVAR");
	if len(env) == 0 {
		panic("Please set required environment variable")
	}

	http.ListenAndServe(":" + port, nil);
}
