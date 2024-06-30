// import { ApolloClient, InMemoryCache, gql } from '@apollo/client';

// const client = new ApolloClient({
//   uri: process.env.NEXT_PUBLIC_API_URL,
//   cache: new InMemoryCache(),
// });

// const HELLO_QUERY = gql`
//   query {
//     hello
//     greet(name: "John")
//   }
// `;

// interface HelloQueryResult {
//   hello: string;
//   greet: string;
// }

// export default function Home({ data }: { data: HelloQueryResult }) {
//   return (
//     <div>
//       <h1>GraphQL API Response</h1>
//       <p>Hello: {data.hello}</p>
//       <p>Greet: {data.greet}</p>
//     </div>
//   );
// }

// export async function getStaticProps() {
//   const { data } = await client.query<HelloQueryResult>({
//     query: HELLO_QUERY,
//   });

//   return {
//     props: {
//       data,
//     },
//   };
// }

export default function Home() {
  return (
    <div>
      <h1>Welcome to Next.js!</h1>
      <p>This is a simple React component.</p>
      <p>API URL: {process.env.NEXT_PUBLIC_API_URL}</p>
    </div>
  );
}