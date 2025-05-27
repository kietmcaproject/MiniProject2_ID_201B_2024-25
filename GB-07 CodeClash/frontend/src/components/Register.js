import { useState } from 'react';
// import { registerUser } from '../api/auth';
import { Link, useNavigate } from 'react-router-dom';
import Navbar from './Navbar';
import { toast, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const Register = () => {
    const [userData, setUserData] = useState({ name: '', username: '', email: '', password: '' });
    const navigate = useNavigate();

    const handleChange = (e) => setUserData({ ...userData, [e.target.name]: e.target.value });

    const check =() => {
        console.log(userData.name);
        console.log(userData.email);
        console.log(userData.password);
    }

   const register = () => {
    if (!userData.username || !userData.name || !userData.email || !userData.password) {
        toast.error("Please enter correct details");
        return;
    }
    fetch('http://localhost:8788/api/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            name: userData.name,
            username: userData.username,
            email: userData.email,
            password: userData.password
        })
    })
    .then(res => res.json())
    .then(data => {
        if (data?.error) {
            toast.error(data.error || 'Registration failed');
        } else {
            toast.success('Registration successful! Please login', { onClose: () => navigate('/login') });
            // navigation handled on toast close
        }
    })
    .catch(err => {
        console.error(err);
        toast.error('Network error');
    });
   }


    return (
        <div>
        <Navbar/>
        <div className="flex items-center justify-center min-h-screen bg-gray-100">
            <div className="bg-white shadow-lg rounded-lg p-8 max-w-md w-full">
                <h2 className="text-2xl font-bold text-gray-800 text-center mb-6">Register</h2>
                <div className="space-y-4">
                    <input 
                        type="text" 
                        name="name" 
                        placeholder="Full Name" 
                        onChange={handleChange} 
                        className="w-full px-4 py-2 border rounded-lg focus:ring focus:ring-green-300 outline-none" 
                    />
                    <input 
                        type="text" 
                        name="username" 
                        placeholder="username" 
                        onChange={handleChange} 
                        className="w-full px-4 py-2 border rounded-lg focus:ring focus:ring-green-300 outline-none" 
                    />
                    <input 
                        type="email" 
                        name="email" 
                        placeholder="Email" 
                        onChange={handleChange} 
                        className="w-full px-4 py-2 border rounded-lg focus:ring focus:ring-green-300 outline-none" 
                    />
                    <input 
                        type="password" 
                        name="password" 
                        placeholder="Password" 
                        onChange={handleChange} 
                        className="w-full px-4 py-2 border rounded-lg focus:ring focus:ring-green-300 outline-none" 
                    />
                    <button 
                        type="submit" 
                        className="w-full bg-green-600 text-white py-2 rounded-lg hover:bg-green-700 transition duration-200"
                        onClick={()=> {register()}}
                    >
                        Register
                    </button>
                </div>
                <p className="text-sm text-center text-gray-600 mt-4">
                    Already have an account? 
                    <Link to="/login" className="text-green-600 hover:underline ml-1">Login</Link>
                </p>
                <ToastContainer position="top-right" autoClose={3000} />
            </div>
        </div>
        </div>
    );
};

export default Register;