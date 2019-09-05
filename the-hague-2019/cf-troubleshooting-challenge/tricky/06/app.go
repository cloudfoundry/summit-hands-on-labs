package main

import (
	"fmt"
	"html/template"
	"net/http"
	"os"
)

func logToFile(logMessage string, logPath string) {
	file, _ := os.OpenFile(logPath, os.O_RDWR|os.O_APPEND|os.O_CREATE, 0666)
	file.WriteString(logMessage)
	defer file.Close()
}

func logToStdout(logMessage string) {
	fmt.Println(logMessage)
}

func logFunc(w http.ResponseWriter, r *http.Request) {
	var logMessage, logPath string
	logPath = "/tmp/applog.log"
	logMessage = "DEBUG: this is test log.\n"
	logToFile(logMessage, logPath)
	t, _ := template.ParseFiles("index.html")
	t.Execute(w, nil)
}

func main() {
	http.HandleFunc("/", logFunc)

	var port string
	port = os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}

	fmt.Print("Run server and listen on port: " + port +" \n")
	http.ListenAndServe(":"+port, nil)
}
