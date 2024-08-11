'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';

// AuthContextTypeインターフェースは、認証コンテキストの形を定義
interface AuthContextType {
  isAuthenticated: boolean;        // ユーザーがログインしているかどうかを示すブール値
  login: (token: string) => void;  // ログイン処理を行う関数。トークンを引数に取ります
  logout: () => void;              // ログアウト処理を行う関数
}

// undefinedは、コンテキストが初期化される前に使用された場合にエラーをスローするためのデフォルト値
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// 認証状態を管理し、子コンポーネントに提供
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // isAuthenticatedの状態とそれを更新する関数を定義
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // コンポーネントがマウントされたときに実行される副作用
  useEffect(() => {
    // ローカルストレージからauthTokenを取得
    const token = localStorage.getItem('authToken');
    // トークンの有無に基づいて認証状態を設定
    setIsAuthenticated(!!token);
  }, []); // 空の依存配列は、この効果がコンポーネントのマウント時にのみ実行されることを意味

  // ログイン関数を定義
  const login = (token: string) => {
    // トークンをローカルストレージに保存
    localStorage.setItem('authToken', token);
    // 認証状態をtrueに設定
    setIsAuthenticated(true);
    // ホームページにリダイレクト
    window.location.href = '/';
  };

  // ログアウト関数を定義
  const logout = () => {
    // ローカルストレージからトークンを削除
    localStorage.removeItem('authToken');
    // 認証状態をfalseに設定
    setIsAuthenticated(false);
    // ログインページにリダイレクト
    window.location.href = '/login';
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