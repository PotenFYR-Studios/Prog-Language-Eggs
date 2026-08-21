package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"runtime"
	"time"
)

type StatusResponse struct {
	Status    string `json:"status"`
	Message   string `json:"message"`
	GoVersion string `json:"go_version"`
	Time      string `json:"timestamp"`
}

func main() {
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = os.Getenv("PORT")
	}
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		resp := StatusResponse{
			Status:    "online",
			Message:   "Hello from PotenFYR Golang Egg!",
			GoVersion: runtime.Version(),
			Time:      time.Now().UTC().Format(time.RFC3339),
		}
		json.NewEncoder(w).Encode(resp)
	})

	fmt.Printf("[PotenFYR] Go HTTP server listening on port %s\n", port)
	if err := http.ListenAndServe("0.0.0.0:"+port, nil); err != nil {
		fmt.Printf("Server failed: %v\n", err)
	}
}
