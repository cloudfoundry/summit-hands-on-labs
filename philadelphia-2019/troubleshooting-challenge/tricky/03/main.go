// THIS APPLICATION DOES NOT SERVE HTTP CONNECTIONS. IT JUST WRITING TEXT TO STDOUT

package main

import (
	"fmt"
	"time"
)

func main() {
	for {
		fmt.Println("CONGRATULATIONS")
		time.Sleep(1 * time.Second)
		fmt.Println("you just completed tricky task #03");
		time.Sleep(1 * time.Second)
	}
}
