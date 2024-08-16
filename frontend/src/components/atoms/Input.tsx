// src/components/atoms/Input.tsx
import React from 'react';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  id: string;
}

const Input: React.FC<InputProps> = ({ id, ...props }) => (
  <input
    className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
    id={id}
    {...props}
  />
);

export default Input;
