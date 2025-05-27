import { useState, useEffect } from "react";
import Navbar2 from "./Navbar2"
import { toast, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

// Material UI imports
import {
    Container,
    Grid,
    Paper,
    Typography,
    Box,
    Avatar,
    Button,
    Divider,
    Card,
    CardContent,
    TextField,
    MenuItem,
    Select,
    InputLabel,
    FormControl,
    Link,
    CircularProgress
} from '@mui/material';

// Icons
import CodeIcon from '@mui/icons-material/Code';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import SchoolIcon from '@mui/icons-material/School';
import GitHubIcon from '@mui/icons-material/GitHub';
import LinkedInIcon from '@mui/icons-material/LinkedIn';

const Profile = () => {
    const token = sessionStorage.getItem('Authtoken');
    const [loading, setLoading] = useState(true);
    const [saveLoading, setSaveLoading] = useState(false);

    const [profile, setProfile] = useState({
        name: "",
        email: "",
        username: "",
        department: "",
        college: "",
        dob: "",
        gender: "",
        profilePicUrl:"",
        phoneNumber: "",
        githubLink: "",
        linkedinLink: "",
    });

    const [profilePic, setProfilePic] = useState(null);
    const [attemptsCount, setAttemptsCount] = useState(0);
    const [highestScore, setHighestScore] = useState(0);
    const [problemsSolved, setProblemsSolved] = useState(0);
    const [codingStreak, setCodingStreak] = useState(0);

    const currentUsername = localStorage.getItem("Username");

    // Function to Fetch User Profile
    const getUserDetails = async () => {
        setLoading(true);
        try {
            const response = await fetch(`http://localhost:8788/api/updateUserProfileGetByUsername/${currentUsername}` , {
                method : "GET",
                headers: {
                    "Authorization": `Bearer ${token}`,  // Correct Bearer Token format
                    "Content-Type": "application/json"  // Required for JSON-based requests
                }
            });
            const data = await response.json();

            // Updating State with API Response, Handling Null Values
            setProfile({
                name: data.name || "",
                email: data.email || "",
                username: data.username || "",
                department: data.department || "",
                college: data.college || "",
                dob: data.dob || "",
                gender: data.gender || "",
                profilePicUrl:data.profilePicUrl || "",
                phoneNumber: data.phoneNumber || "",
                githubLink: data.githubLink || "",
                linkedinLink: data.linkedinLink || "",
            });

            // Set Profile Picture if Available
            if (data.profilePicUrl) {
                setProfilePic(data.profilePicUrl);
            }
            
            // Mock data for coding stats (replace with actual API data when available)
            setProblemsSolved(Math.floor(Math.random() * 30) + 5);
            setCodingStreak(Math.floor(Math.random() * 10) + 1);
            
            setLoading(false);
        } catch (error) {
            console.error("Error fetching user details:", error);
            toast.error("Failed to load profile data");
            setLoading(false);
        }
    };

    useEffect(() => {
        getUserDetails();

        console.log(profile);
        
    }, []);

    useEffect(() => {
        fetch(`http://localhost:8788/api/quiz/getResults?username=${currentUsername}`)
            .then(res => res.json())
            .then(data => {
                setAttemptsCount(data.length);
                const max = data.length > 0 ? Math.max(...data.map(r => r.score)) : 0;
                setHighestScore(max);
            })
            .catch(err => {
                console.error("Error fetching quiz stats:", err);
                toast.error("Failed to load quiz stats");
            });
    }, [currentUsername]);

    const handleChange = (e) => {
        setProfile({ ...profile, [e.target.name]: e.target.value });
    };

    const handleImageChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            const imageUrl = URL.createObjectURL(file);
            setProfilePic(imageUrl);
        }
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        updateUser();
    };

    const updateUser = async () => {
        setSaveLoading(true);
        try{
            const response = await fetch(`http://localhost:8788/api/updateUserProfile/${currentUsername}`, {
                method: "PUT",
                headers: {
                    "Authorization": `Bearer ${token}`, 
                    "Content-Type": "application/json"  
                },
                body: JSON.stringify(profile)
            });

            const updateItem = await response.json()
            postDetails();
            toast.success("Profile updated successfully");
        }catch(e){
            console.error("Error" , e);
            toast.error("Failed to update profile");
        } finally {
            setSaveLoading(false);
        }
    }

    const postDetails = async () => {
        if (!profilePic) {
            console.log("No image selected");
            return;
        }
    
        const data = new FormData();
        data.append("file", profilePic); // Append image file
        data.append("upload_preset", "your_upload_preset"); // Replace with your Cloudinary upload preset
        data.append("cloud_name", "your_cloud_name"); // Replace with your Cloudinary cloud name
    
        try {
            const response = await fetch("https://api.cloudinary.com/v1_1/your_cloud_name/image/upload", {
                method: "POST",
                body: data
            });
    
            const cloudinaryData = await response.json();
    
            if (cloudinaryData.secure_url) {
                console.log("Image uploaded successfully:", cloudinaryData.secure_url);
                setProfilePic(cloudinaryData.secure_url); // Update profile picture state
                setProfile({ ...profile, profilePicUrl: cloudinaryData.secure_url }); // Update profile state
            } else {
                console.error("Error uploading image:", cloudinaryData);
            }
        } catch (error) {
            console.error("Upload failed:", error);
        }
    };

    if (loading) {
        return (
            <>
                <Navbar2 />
                <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
                    <CircularProgress />
                </Box>
            </>
        );
    }

    return (
        <Box sx={{ bgcolor: '#f5f7fa', minHeight: '100vh' }}>
            <Navbar2 />
            <Container maxWidth="lg" sx={{ mt: 4, mb: 8 }}>
                {/* Header */}
                <Paper 
                    elevation={3} 
                    sx={{ 
                        p: 4, 
                        borderRadius: 2, 
                        mb: 4, 
                        background: 'linear-gradient(135deg, #6a11cb 0%, #2575fc 100%)',
                        color: 'white',
                        textAlign: 'center'
                    }}
                >
                    <Typography variant="h4" fontWeight="bold" gutterBottom align="center">
                        Developer Profile
                    </Typography>
                    <Typography variant="subtitle1" align="center">
                        Manage your personal information and view your coding achievements
                    </Typography>
                </Paper>

                <Grid container spacing={4} sx={{ mb: 4 }} justifyContent="center">
                    {/* Left Column - Profile Info */}
                    <Grid item xs={12} md={4} sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                        <Paper elevation={2} sx={{ p: 2, borderRadius: 2, height: '100%' }}>
                            {/* Profile Picture */}
                            <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 3 }}>
                                <label htmlFor="profilePic" style={{ cursor: 'pointer' }}>
                                    <Avatar 
                                        src={profilePic} 
                                        sx={{ 
                                            width: 120, 
                                            height: 120, 
                                            mb: 2,
                                            border: '4px solid #6a11cb'
                                        }}
                                    >
                                        {profile.name ? profile.name.charAt(0).toUpperCase() : '?'}
                                    </Avatar>
                                    <input type="file" id="profilePic" style={{ display: 'none' }} accept="image/*" onChange={handleImageChange} />
                                </label>
                                <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                    Click to change profile picture
                                </Typography>
                                <Typography variant="h5" fontWeight="bold">
                                    {profile.name || currentUsername}
                                </Typography>
                                <Typography variant="body2" color="text.secondary">
                                    {profile.email}
                                </Typography>
                            </Box>

                            <Divider sx={{ my: 2 }} />

                            {/* Stats Cards */}
                            <Typography variant="h6" gutterBottom align="center">
                                Coding Stats
                            </Typography>
                            <Grid container spacing={2} sx={{ mb: 3 }}>
                                <Grid item xs={12} sm={6}>
                                    <Card sx={{ bgcolor: '#f0f4ff', height: '100%', boxShadow: 2 }}>
                                        <CardContent sx={{ textAlign: 'center', py: 3 }}>
                                            <CodeIcon sx={{ color: '#2575fc', fontSize: 40, mb: 1 }} />
                                            <Typography variant="h5" fontWeight="bold">
                                                {problemsSolved}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                Problems Solved
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                    <Card sx={{ bgcolor: '#fff4f0', height: '100%', boxShadow: 2 }}>
                                        <CardContent sx={{ textAlign: 'center', py: 3 }}>
                                            <EmojiEventsIcon sx={{ color: '#ff6b35', fontSize: 40, mb: 1 }} />
                                            <Typography variant="h5" fontWeight="bold">
                                                {highestScore}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                Highest Score
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                    <Card sx={{ bgcolor: '#f0fff4', height: '100%', boxShadow: 2 }}>
                                        <CardContent sx={{ textAlign: 'center', py: 3 }}>
                                            <SchoolIcon sx={{ color: '#4CAF50', fontSize: 40, mb: 1 }} />
                                            <Typography variant="h5" fontWeight="bold">
                                                {attemptsCount}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                Quiz Attempts
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                    <Card sx={{ bgcolor: '#f4f0ff', height: '100%', boxShadow: 2 }}>
                                        <CardContent sx={{ textAlign: 'center', py: 3 }}>
                                            <CodeIcon sx={{ color: '#9c27b0', fontSize: 40, mb: 1 }} />
                                            <Typography variant="h5" fontWeight="bold">
                                                {codingStreak}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                Day Streak
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Grid>
                            </Grid>

                            {/* Social Links */}
                            {(profile.githubLink || profile.linkedinLink) && (
                                <>
                                    <Typography variant="h6" gutterBottom align="center">
                                        Connect
                                    </Typography>
                                    <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2, mb: 2 }}>
                                        {profile.githubLink && (
                                            <Link href={profile.githubLink} target="_blank" rel="noopener">
                                                <Button 
                                                    variant="outlined" 
                                                    startIcon={<GitHubIcon />}
                                                    sx={{ borderRadius: 2 }}
                                                >
                                                    GitHub
                                                </Button>
                                            </Link>
                                        )}
                                        {profile.linkedinLink && (
                                            <Link href={profile.linkedinLink} target="_blank" rel="noopener">
                                                <Button 
                                                    variant="outlined" 
                                                    startIcon={<LinkedInIcon />}
                                                    sx={{ borderRadius: 2 }}
                                                >
                                                    LinkedIn
                                                </Button>
                                            </Link>
                                        )}
                                    </Box>
                                </>
                            )}
                        </Paper>
                    </Grid>

                    {/* Right Column - Edit Form */}
                    <Grid item xs={12} md={8}>
                        <Paper elevation={2} sx={{ p: 3, borderRadius: 2 }}>
                            <Typography variant="h5" fontWeight="bold" gutterBottom align="center">
                                Edit Profile
                            </Typography>
                            <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }} align="center">
                                Update your personal information
                            </Typography>

                            <form onSubmit={handleSubmit} style={{ textAlign: 'center' }}>
                                <Grid container spacing={3} justifyContent="center" sx={{ maxWidth: '90%', mx: 'auto' }}>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="Full Name"
                                            name="name"
                                            value={profile.name}
                                            onChange={handleChange}
                                            variant="outlined"
                                        />
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="Email"
                                            type="email"
                                            name="email"
                                            value={profile.email}
                                            disabled
                                            variant="outlined"
                                        />
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="Username"
                                            name="username"
                                            value={currentUsername}
                                            disabled
                                            variant="outlined"
                                        />
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="Department"
                                            name="department"
                                            value={profile.department}
                                            onChange={handleChange}
                                            variant="outlined"
                                        />
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="College/University"
                                            name="college"
                                            value={profile.college}
                                            onChange={handleChange}
                                            variant="outlined"
                                        />
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="Date of Birth"
                                            type="date"
                                            name="dob"
                                            value={profile.dob}
                                            onChange={handleChange}
                                            variant="outlined"
                                            InputLabelProps={{ shrink: true }}
                                        />
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <FormControl fullWidth variant="outlined">
                                            <InputLabel>Gender</InputLabel>
                                            <Select
                                                name="gender"
                                                value={profile.gender}
                                                onChange={handleChange}
                                                label="Gender"
                                            >
                                                <MenuItem value="">Select Gender</MenuItem>
                                                <MenuItem value="Male">Male</MenuItem>
                                                <MenuItem value="Female">Female</MenuItem>
                                                <MenuItem value="Other">Other</MenuItem>
                                            </Select>
                                        </FormControl>
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="Phone Number"
                                            name="phoneNumber"
                                            value={profile.phoneNumber}
                                            onChange={handleChange}
                                            variant="outlined"
                                        />
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="GitHub Profile URL"
                                            name="githubLink"
                                            value={profile.githubLink}
                                            onChange={handleChange}
                                            variant="outlined"
                                            placeholder="https://github.com/username"
                                        />
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <TextField
                                            fullWidth
                                            label="LinkedIn Profile URL"
                                            name="linkedinLink"
                                            value={profile.linkedinLink}
                                            onChange={handleChange}
                                            variant="outlined"
                                            placeholder="https://linkedin.com/in/username"
                                        />
                                    </Grid>
                                    <Grid item xs={12}>
                                        <Button 
                                            type="submit" 
                                            variant="contained" 
                                            fullWidth 
                                            disabled={saveLoading}
                                            sx={{ 
                                                mt: 2, 
                                                py: 1.5, 
                                                background: 'linear-gradient(90deg, #6a11cb 0%, #2575fc 100%)',
                                                '&:hover': {
                                                    background: 'linear-gradient(90deg, #5910b0 0%, #1e68e0 100%)',
                                                }
                                            }}
                                        >
                                            {saveLoading ? <CircularProgress size={24} color="inherit" /> : 'Update Profile'}
                                        </Button>
                                    </Grid>
                                </Grid>
                            </form>
                        </Paper>
                    </Grid>
                </Grid>
            </Container>
            <ToastContainer position="top-right" autoClose={3000} />
        </Box>
    );
};

export default Profile;