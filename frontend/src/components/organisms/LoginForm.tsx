// src/components/organisms/LoginForm.tsx
import React, { useState } from 'react';
import FormField from '../molecules/FormField';
import Button from '../atoms/Button';
import { login } from '../../lib/api';

const LoginForm: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const result = await login(email, password);
      if (result.error) {
        setError(result.error);
      } else {
        console.log('ログインに成功しました', result);
      }
    } catch (err) {
      setError('エラーが発生しました。もう一度お試しください。');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4">
      <FormField
        id="email"
        label="Email"
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <FormField
        id="password"
        label="Password"
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      {error && <p className="text-red-500 text-xs italic">{error}</p>}
      <div className="flex items-center justify-between">
        <Button type="submit">ログイン</Button>
      </div>
    </form>
  );
};

export default LoginForm;
