import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { toast, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import './Navbar.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import {
    FaHome,
    FaUser,
    FaSignInAlt,
    FaSearch,
    FaGlobe,
    FaSignOutAlt,
    } from "react-icons/fa";

const Navbar = () => {
    const [isLoggedIn, setIsLoggedIn] = useState(false);

    useEffect(() => {
        // Check if user data is present in local storage
        const userData = localStorage.getItem('user');
        setIsLoggedIn(!!userData);
    }, []);

    const handleLogout = () => {
        // Remove user data from local storage
        localStorage.removeItem('user');
        setIsLoggedIn(false);
        toast.success("Logged out successfully!");
    };

    return (
        <>
            {/* All linking section is here */}
            <section>
                <div className='d-flex justify-between items-center gap-4 bg-gray-950 py-2 text-white container-fluid mobileview'>
                    <div className="d-flex flex-wrap items-center gap-4 container-fluid linksarea">
                        <Link to="/"><FaHome className='text-blue-400'/>Home</Link>
                        <Link to="/about"><FaUser className='text-green-400'/>About</Link>
                        <Link to="/flowchartdisplay"><FaSearch className='text-yellow-400'/>CodHelp Roadmap Search...</Link>
                        <Link to="/Flowcharteditor"><i class="text-yellow-400 bi bi-pencil-square"></i>CodHelp Editor</Link>
                        {/* <Link to="https://myportfoliobyvikassingh.netlify.app" className='text-capitalize' target='_blank'>
                            <FaGlobe className='text-red-400 text-xl'/>Visit Myportfolio
                        </Link> */}
                    </div>
                    <div className="d-flex flex-wrap justify-end items-center gap-4 text-capitalize container-fluid smallviewpostion">
                        {isLoggedIn ? (
                            <button onClick={handleLogout} className='d-flex items-center gap-2 btn btn-danger btn-sm'>
                                <FaSignOutAlt/>Log out
                            </button>
                        ) : (
                            <>
                                <Link to="/login">
                                    <button className='d-flex items-center gap-2 btn btn-primary btn-sm'><FaSignInAlt/>Log in</button>
                                </Link>
                                <Link to="/registration">
                                    <button className='d-flex items-center gap-2 btn btn-sm btn-success'><FaSignInAlt/>Registration</button>
                                </Link>
                            </>
                        )}
                    </div>
                </div>
            </section>
            <ToastContainer />
        </>
    );
};

export default Navbar;
