'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';  // next/routerからnext/navigationに変更
import LoginForm from '../organisms/LoginForm';
import { useAuth } from '../../contexts/AuthContext';

const LoginPage: React.FC = () => {
  const { isAuthenticated } = useAuth();
  const router = useRouter();

  // isAuthenticatedがtrueの場合、ホームページにリダイレクト
  useEffect(() => {
    if (isAuthenticated) {
      router.push('/');
    }
  }, [isAuthenticated, router]);

  return (
    <div className="min-h-screen bg-gray-100 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
          あなたのアカウントにログイン
        </h2>
      </div>
      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <LoginForm />
      </div>
    </div>
  );
};

export default LoginPage;
