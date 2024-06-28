package graph

import (
	"context"
	"golang/graph/generated"
)

type Resolver struct{}

func (r *Resolver) Query() generated.QueryResolver {
	return &queryResolver{r}
}

type queryResolver struct{ *Resolver }

func (r *queryResolver) Hello(ctx context.Context) (string, error) {
	return "Hello, world!", nil
}

func (r *queryResolver) Greet(ctx context.Context, name string) (string, error) {
	return "Hello, " + name + "!", nil
}
