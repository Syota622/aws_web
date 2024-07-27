// src/components/templates/LoginPage.tsx
import React from 'react';
import LoginForm from '../organisms/LoginForm';

const LoginPage: React.FC = () => (
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

export default LoginPage;
