import React from 'react';
import { Link } from "react-router-dom";

function Navbar() {
  return (
    <div>
      <nav className="flex justify-between items-center p-6 bg-gray-800">
        <h1 className="text-2xl font-bold text-purple-400">CodeClash</h1>
        <div className="space-x-6">
          <Link to="/login" className="px-4 py-2 bg-purple-500 hover:bg-blue-600 rounded-lg">
            Login
          </Link>
          <Link to="/register" className="px-4 py-2 bg-purple-500 hover:bg-purple-600 rounded-lg">
            Register
          </Link>
        </div>
      </nav>
    </div>
  );
}

export default Navbar;