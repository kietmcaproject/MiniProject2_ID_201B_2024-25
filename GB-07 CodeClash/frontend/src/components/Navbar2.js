import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from "react-router-dom";
import { toast } from 'react-toastify';
import './navbar.css';
import { useNavbarVisibility } from './NavbarVisibilityContext';

function Navbar() {
  const { navbarVisible } = useNavbarVisibility();
  const [isAuthenticated, setIsAuthenticated] = useState(true);
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const handleScroll = () => {
      const offset = window.scrollY;
      setScrolled(offset > 50);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  if (!navbarVisible) return null;


  const handleLogout = () => {
    // Clear user authentication (e.g., remove token)
    setIsAuthenticated(false);
    localStorage.removeItem('Username');
    sessionStorage.removeItem('Authtoken');
    toast.info('Logged out successfully', { onClose: () => navigate('/login') });
    navigate('/login'); // Redirect to login page
    // navigation handled after toast closes
  };

  return (
    <div>
      <nav className={`fixed w-full z-50 transition-all duration-300 ${scrolled ? 'nav-scrolled' : ''} ${isOpen ? 'nav-open' : ''}`}>
        <div className="container mx-auto px-4">
          <div className="flex justify-between items-center py-4">
            <h1 onClick={() => navigate('/')} className="text-2xl font-bold text-purple-400 flex items-center cursor-pointer">
              <span className="mr-2">⚡</span> CodeClash
            </h1>

            {/* Hamburger Menu */}
            <button
              onClick={() => setIsOpen(!isOpen)}
              className="lg:hidden focus:outline-none transition-transform duration-300 transform hover:scale-110"
            >
              <div className={`hamburger ${isOpen ? 'open' : ''}`}>
                <span></span>
                <span></span>
                <span></span>
              </div>
            </button>

            {/* Navigation Links */}
            <div className={`lg:flex items-center space-x-1 ${isOpen ? 'mobile-menu-open' : 'mobile-menu-closed'}`}>
              <Link to="/quiz" className="px-3 py-2 text-gray-300 hover:text-white hover:underline transition-colors duration-200">Mock Test</Link>
              <Link to="/performance" className="px-3 py-2 text-gray-300 hover:text-white hover:underline transition-colors duration-200">Performance</Link>
            {/*  <Link to="/joinroom" className="px-3 py-2 text-gray-300 hover:text-white hover:underline transition-colors duration-200">Join Room</Link> */}
              <Link to="/profile" className="px-3 py-2 text-gray-300 hover:text-white hover:underline transition-colors duration-200">Profile</Link>
              {/* <Link to="/practice" className="px-3 py-2 text-gray-300 hover:text-white hover:underline transition-colors duration-200">Practice</Link> */}
              <Link to="/problemset" className="px-3 py-2 text-gray-300 hover:text-white hover:underline transition-colors duration-200">Problem Set</Link>

              {isAuthenticated ? (
                <button onClick={handleLogout} className="px-3 py-2 text-gray-300 hover:text-white hover:underline transition-colors duration-200">Logout</button>
              ) : (
                <Link to="/register" className="px-3 py-2 text-gray-300 hover:text-white hover:underline transition-colors duration-200">Register</Link>
              )}
            </div>
          </div>
        </div>
      </nav>
      {/* Spacer to prevent content from hiding under fixed navbar */}
      <div className="h-20"></div>
    </div>
  );
}

export default Navbar;