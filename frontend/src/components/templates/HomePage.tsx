'use client';

import React, { useEffect } from 'react';
import { useAuth } from '../../contexts/AuthContext';

const HomePage: React.FC = () => {
  // authTokenを取得してログインしているかどうかを判定
  const { isAuthenticated, logout } = useAuth();

  useEffect(() => {
    if (!isAuthenticated) {
      window.location.href = '/login';
    }
  }, [isAuthenticated]);

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="max-w-4xl mx-auto p-4">
      <header className="flex items-center justify-between mb-6">
        <div className="w-10 h-10 bg-gray-300 rounded-full"></div>
        <div className="flex-grow mx-4 relative">
          <input
            type="text"
            placeholder="ロードマップ検索"
            className="w-full py-2 pl-10 pr-4 border rounded-lg"
          />
          <span className="absolute left-3 top-1/2 transform -translate-y-1/2">🔍</span>
        </div>
        <div className="flex space-x-2">
          <span className="text-2xl">☆</span>
          <span className="text-2xl">☆</span>
        </div>
      </header>

      <nav className="flex justify-between mb-6">
        {['おすすめ', 'IT', '恋愛', '簿記'].map((category) => (
          <button
            key={category}
            className="px-4 py-2 bg-gray-200 rounded-lg hover:bg-gray-300 transition-colors"
          >
            {category}
          </button>
        ))}
      </nav>

      <main className="grid grid-cols-2 gap-4">
        {[1, 2, 3, 4].map((num) => (
          <div
            key={num}
            className="bg-gray-200 p-4 rounded-lg flex items-center justify-center h-40 hover:bg-gray-300 transition-colors"
          >
            <span className="text-xl font-bold">ロードマップ{num}</span>
          </div>
        ))}
      </main>

      <footer>
        <button onClick={logout}>ログアウト</button>
      </footer>
    </div>
  );
};

export default HomePage;