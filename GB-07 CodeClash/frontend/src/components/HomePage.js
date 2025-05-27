import React, { useEffect } from "react";
import Navbar1 from "./Navbar";
import Navbar2 from "./Navbar2";
import { useNavigate } from "react-router-dom";
import './scrollbar.css';
import { toast, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const Home = () => {
  // Custom scrollbar styles
  useEffect(() => {
    document.body.style.scrollBehavior = 'smooth';
    document.body.style.overflowY = 'overlay';
    return () => {
      document.body.style.scrollBehavior = 'auto';
      document.body.style.overflowY = 'auto';
    };
  }, []);

  const AuthToken = sessionStorage.getItem('Authtoken');
  const navigate = useNavigate();




  return (
    <div className="bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900 text-white min-h-screen transition-all duration-300 ease-in-out"
      style={{
        '--scrollbar-color': '#9333ea',
        '--scrollbar-bg': 'rgba(17, 24, 39, 0.1)',
      }}>
      {AuthToken ? <Navbar2 /> : <Navbar1 />}

      {/* Hero Section */}
      <header className="text-center py-20 px-4 animate-fadeIn">
        <h2 className="text-5xl font-bold">
          Welcome to <span className="text-purple-400">CodeClash</span>
        </h2>
        <p className="mt-4 text-gray-300 max-w-xl mx-auto">
          Join real-time coding battles, solve challenges, and climb the leaderboard.
        </p>
        <div className="mt-6 space-x-4">
          <button  onClick={() => { if (!AuthToken) toast.error('Please login to continue'); else navigate('/quiz'); }} className="bg-purple-600 px-6 py-3 rounded-lg transform hover:scale-105 hover:bg-purple-500 transition-all duration-300 shadow-lg hover:shadow-purple-500/50">
            Start Your Test
          </button>
          <button  onClick={() => { if (!AuthToken) toast.error('Please login to continue'); else navigate('/performance'); }} className="bg-gray-700 px-6 py-3 rounded-lg transform hover:scale-105 hover:bg-gray-600 transition-all duration-300 shadow-lg hover:shadow-gray-600/50">
            View Performance
          </button>
        </div>
      </header>

      {/* How CodeClash Works */}
      <section className="text-center py-16">
        <h3 className="text-2xl font-bold">How CodeClash Works?</h3>
        <div className="grid md:grid-cols-3 gap-8 mt-6 px-6">
          <div className="bg-gray-800/50 backdrop-blur-sm p-6 rounded-lg shadow-lg transform hover:scale-105 hover:bg-gray-800 transition-all duration-300 border border-gray-700 hover:border-purple-500">
            <h4 className="text-lg font-bold">🔹 Join or Create a Room</h4>
            <p className="text-gray-400 mt-2">Compete in real-time coding battles.</p>
          </div>
          <div className="bg-gray-800/50 backdrop-blur-sm p-6 rounded-lg shadow-lg transform hover:scale-105 hover:bg-gray-800 transition-all duration-300 border border-gray-700 hover:border-purple-500">
            <h4 className="text-lg font-bold">🔹 Solve Coding Challenges</h4>
            <p className="text-gray-400 mt-2">Test your problem-solving skills.</p>
          </div>
          <div className="bg-gray-800/50 backdrop-blur-sm p-6 rounded-lg shadow-lg transform hover:scale-105 hover:bg-gray-800 transition-all duration-300 border border-gray-700 hover:border-purple-500">
            <h4 className="text-lg font-bold">🔹 Rank Up & Win</h4>
            <p className="text-gray-400 mt-2">Climb the leaderboard with every win.</p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-800 text-center py-6">
        <p className="text-gray-400">&copy; 2025 CodeClash. All Rights Reserved.</p>
      </footer>
      <ToastContainer position="top-right" autoClose={3000} />
    </div>
  );
};

export default Home;