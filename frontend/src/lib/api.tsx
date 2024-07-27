// src/lib/api.ts
import { ApolloClient, InMemoryCache, gql, ApolloError } from '@apollo/client';

const client = new ApolloClient({
  uri: process.env.NEXT_PUBLIC_API_URL || 'http://host.docker.internal:8080/query',
  cache: new InMemoryCache(),
});

export const login = async (email: string, password: string) => {
  const LOGIN_MUTATION = gql`
    mutation Login($email: String!, $password: String!) {
      login(input: { email: $email, password: $password }) {
        token
        user {
          id
          username
          email
        }
        error
      }
    }
  `;

  try {
    const { data } = await client.mutate({
      mutation: LOGIN_MUTATION,
      variables: { email, password },
    });
    
    if (data.login.error) {
      console.error('Login API error:', data.login.error);
      return { error: data.login.error };
    }
    
    return data.login;
  } catch (error) {
    if (error instanceof ApolloError) {
      console.error('Apollo error:', error.message, error.graphQLErrors, error.networkError);
    } else {
      console.error('Unexpected error:', error);
    }
    return { error: 'ログイン中に、エラーが発生しました。もう一度お試しください。' };
  }
};