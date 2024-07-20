// Code generated by github.com/99designs/gqlgen, DO NOT EDIT.

package model

type LoginInput struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type LoginPayload struct {
	Token *string `json:"token,omitempty"`
	User  *User   `json:"user,omitempty"`
	Error *string `json:"error,omitempty"`
}

type Mutation struct {
}

type Query struct {
}

type User struct {
	ID       string  `json:"id"`
	Username string  `json:"username"`
	Email    *string `json:"email,omitempty"`
}
