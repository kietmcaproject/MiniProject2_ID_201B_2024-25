import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from './Navbar';
import { toast, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const Login = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [token, setToken] = useState('');
    const navigate = useNavigate();

    const login = () => {

        if (!username || !password) {
            toast.error("Please enter all the details");
            return;
        }

        fetch('http://localhost:8788/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type':'application/json'
            },
            body: JSON.stringify({
                username: username,
                password: password
            })
        })
        .then(res => res.json())
        .then(data => {
            if (data?.error) {
                toast.error(data.error || "Login failed");
            } else {
                toast.success("Login successful", { onClose: () => navigate('/') });
                setToken(data.accessToken);
                setUsername(data.username);
                localStorage.setItem('Username', data.username);
                sessionStorage.setItem('Authtoken', data.accessToken);
                // navigation handled after toast closes
            }
        })
        .catch(err => {
            console.error("Fetch error: ", err);
            toast.error("Network error");
        });

    }



    return (
        <div>
        <Navbar/>
        <div className="flex items-center justify-center min-h-screen bg-gray-100">
            <div className="bg-white shadow-lg rounded-lg p-8 max-w-md w-full">
                <h2 className="text-2xl font-bold text-gray-800 text-center mb-6">Login</h2>
                <div className="space-y-4">
                    <input 
                        type="username" 
                        value={username} 
                        onChange={(e) => setUsername(e.target.value)} 
                        placeholder="username" 
                        className="w-full px-4 py-2 border rounded-lg focus:ring focus:ring-blue-300 outline-none" 
                    />
                    <input 
                        type="password" 
                        value={password} 
                        onChange={(e) => setPassword(e.target.value)} 
                        placeholder="Password" 
                        className="w-full px-4 py-2 border rounded-lg focus:ring focus:ring-blue-300 outline-none" 
                    />
                    <button 
                        type="submit" 
                        className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition duration-200"
                        onClick={()=> {login()}}
                    >
                        Login
                    </button>
                </div>
                <p className="text-sm text-center text-gray-600 mt-4">
                    Don't have an account? 
                    <a href="/register" className="text-blue-600 hover:underline ml-1">Register</a>
                </p>
            </div>
            <ToastContainer position="top-right" autoClose={3000} />
        </div>
        </div>
    );
};

export default Login;