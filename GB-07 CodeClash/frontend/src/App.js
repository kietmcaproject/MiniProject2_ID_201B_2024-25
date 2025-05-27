import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Login from './components/Login';
import Register from './components/Register';
import Profile from './components/Profile';
import HomePage from './components/HomePage'
import Navbar2 from './components/Navbar2';
import { NavbarVisibilityProvider, useNavbarVisibility } from './components/NavbarVisibilityContext';
import CreateRoom from './components/CreateRoom';
import JoinPage from './components/JoinPage';
import QuizComponent from './components/QuizComponent';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import Performance from './components/Performance';
import ProblemSetPage from './components/ProblemSetPage';
import PracticePage from './components/PracticePage';

const NavbarController = () => {
  const { navbarVisible } = useNavbarVisibility();
  return navbarVisible ? <Navbar2 /> : null;
};

const App = () => {
    return (
        <NavbarVisibilityProvider>
            <BrowserRouter>
                <ToastContainer position="top-right" autoClose={3000} hideProgressBar={false} newestOnTop={false} closeOnClick rtl={false} pauseOnFocusLoss draggable pauseOnHover />
                <Routes>
                <Route path="/" element={<HomePage />}/>
                <Route path="/login" element={<Login />} />
                <Route path="/register" element={<Register />} />
                <Route path="/profile" element={<Profile />} />
                <Route path="/createroom" element={<CreateRoom/>}></Route>
                <Route path="/joinroom" element={<JoinPage/>}></Route>
                <Route path="/quiz" element={<QuizComponent/>}></Route>
                <Route path="/practicepage" element={<PracticePage />} />
                <Route path="/problemset" element={<ProblemSetPage />} />
                <Route path="/performance" element={<Performance/>}></Route>
                </Routes>
            </BrowserRouter>
        </NavbarVisibilityProvider>
    );
};

export default App;