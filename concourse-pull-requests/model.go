package main

import (
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/nanobox-io/golang-scribble"
)

type ToDo struct {
	UID     string `json:"id"`
	Name    string `json:"name"`
	Created string `json:"created"`
	Done    string `json:"done"`
}

//type ToDoCollection []ToDo

//func (toDos *ToDoCollection) getAll(db *scribble.Driver) {
//  records, _ := db.ReadAll("toDo")
//
//  for _, record := range records{
//    toDo := ToDo{}
//    json.Unmarshal([]byte(record), &toDo)
//    *toDos=append(*toDos, toDo)
//  }
//}
func (toDo *ToDo) getToDo(db *scribble.Driver) {
	db.Read("toDo", toDo.UID, &toDo)
}
func (toDo *ToDo) putToDo(db *scribble.Driver) {
	if toDo.UID == "" {
		toDo.UID = uuid.Must(uuid.NewRandom()).String()
	}
	db.Write("toDo", toDo.UID, toDo)
}
func (toDo *ToDo) finish(db *scribble.Driver) {
	if toDo.UID == "" {
		fmt.Println("This todo cannot be finished as it does not exist yet")
	}
	toDo.Done = time.Now().String()
	db.Write("toDo", toDo.UID, toDo)
}
