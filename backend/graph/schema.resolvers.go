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
