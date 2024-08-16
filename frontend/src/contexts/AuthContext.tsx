'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

// AuthContextTypeインターフェースは、認証コンテキストの形を定義
interface AuthContextType {
  isAuthenticated: boolean;        // ユーザーがログインしているかどうかを示すブール値
  login: (token: string) => void;  // ログイン処理を行う関数。トークンを引数に取ります
  logout: () => void;              // ログアウト処理を行う関数
}

// AuthContextType か undefined の型を持ち、初期値が undefined であるコンテキストを作成
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// 認証状態を管理し、子コンポーネントに提供
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const router = useRouter();

  // コンポーネントがマウントされたときに実行される副作用
  useEffect(() => {
    const token = localStorage.getItem('authToken');
    setIsAuthenticated(!!token); // !!は、値を真偽値に変換するために使用
  }, []); // 空の依存配列は、この効果がコンポーネントのマウント時にのみ実行されることを意味

  // ログイン関数を定義
  const login = (token: string) => {
    localStorage.setItem('authToken', token);
    setIsAuthenticated(true);
    // window.location.href = '/'; // リダイレクト
    router.push('/');
  };

  // ログアウト関数を定義
  const logout = () => {
    localStorage.removeItem('authToken');
    setIsAuthenticated(false);
    // window.location.href = '/login';
    router.push('/login');
  };

  // AuthContext.Providerを返し、値としてisAuthenticated, login, logoutを提供
  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

// useAuth カスタムフックを定義。これにより他のコンポーネントが認証コンテキストを簡単に使用できます
export const useAuth = () => {
  // useContextを使ってAuthContextの値を取得
  const context = useContext(AuthContext);
  // コンテキストが未定義の場合（AuthProvider外で使用された場合）エラーを投げます
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  // コンテキストを返
  return context;
};