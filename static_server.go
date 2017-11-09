package main

import "net/http"

func main() {
	panic(http.ListenAndServe(":4040", http.FileServer(http.Dir("/data"))))
}
