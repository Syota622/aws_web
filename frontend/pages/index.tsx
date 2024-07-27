// pages/index.tsx
import type { NextPage } from 'next';
import Link from 'next/link';

const Home: NextPage = () => (
  <div className="min-h-screen bg-gray-100 flex flex-col justify-center items-center">
    <h1 className="text-4xl font-bold mb-4">Welcome to our App</h1>
    <Link href="/login" className="text-blue-500 hover:text-blue-700">
      Go to Login
    </Link>
  </div>
);

export default Home;
