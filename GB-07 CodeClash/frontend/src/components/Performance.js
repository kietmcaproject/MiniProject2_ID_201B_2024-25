import React, { useState, useEffect } from 'react';
import Navbar2 from './Navbar2';
import { toast } from 'react-toastify';
import {
  Container,
  Typography,
  Table,
  TableHead,
  TableRow,
  TableCell,
  TableBody,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Box,
  CircularProgress,
  Paper,
  Grid,
  Card,
  CardContent,
  Divider,
} from '@mui/material';

// Import icons
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import AssignmentIcon from '@mui/icons-material/Assignment';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import AccessTimeIcon from '@mui/icons-material/AccessTime';

const Performance = () => {
  const username = localStorage.getItem('Username') || 'anonymous';
  const [results, setResults] = useState([]);
  const [filter, setFilter] = useState('all');
  const [average, setAverage] = useState(0);
  const [highestScore, setHighestScore] = useState(0);
  const [totalQuestions, setTotalQuestions] = useState(0);
  const [loading, setLoading] = useState(true);
  const [questionStats, setQuestionStats] = useState({
    easy: 0,
    medium: 0,
    hard: 0
  });

  useEffect(() => {
    setLoading(true);
    fetch(`http://localhost:8788/api/quiz/getResults?username=${username}`)
      .then(res => res.json())
      .then(data => {
        setResults(data);
        
        // Calculate question stats (mock data - replace with actual API data)
        setQuestionStats({
          easy: Math.floor(Math.random() * 15) + 5,
          medium: Math.floor(Math.random() * 10) + 3,
          hard: Math.floor(Math.random() * 5) + 1
        });
        
        setLoading(false);
      })
      .catch(err => {
        console.error('Error loading performance:', err);
        toast.error('Failed to load performance data');
        setLoading(false);
      });
  }, [username]);

  useEffect(() => {
    if (results.length > 0) {
      // Calculate average score
      const avg = results.reduce((sum, r) => sum + r.score, 0) / results.length;
      setAverage(avg.toFixed(2));
      
      // Find highest score
      const highest = Math.max(...results.map(r => r.score));
      setHighestScore(highest);
      
      // Count total questions attempted
      setTotalQuestions(results.length);
    }
  }, [results]);

  const filterResults = () => {
    const now = new Date();
    let filtered = results;
    if (filter === 'week') {
      const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      filtered = results.filter(r => new Date(r.date) >= weekAgo);
    } else if (filter === 'month') {
      const monthAgo = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
      filtered = results.filter(r => new Date(r.date) >= monthAgo);
    }
    return filtered.sort((a, b) => b.score - a.score);
  };

  const displayed = filterResults();

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
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Paper elevation={3} sx={{ p: 4, borderRadius: 2, mb: 4, background: 'linear-gradient(135deg, #6a11cb 0%, #2575fc 100%)', textAlign: 'center' }}>
          <Typography variant="h4" gutterBottom sx={{ color: 'white', fontWeight: 'bold' }} align="center">
            Performance Dashboard
          </Typography>
          <Typography variant="subtitle1" sx={{ color: 'rgba(255,255,255,0.8)' }} align="center">
            Track your progress and improve your coding skills
          </Typography>
        </Paper>

        {/* Stats Cards */}
        <Grid container spacing={4} sx={{ mb: 4 }}>
          <Grid item xs={12} sm={6} md={3}>
            <Card elevation={2} sx={{ height: '100%', borderRadius: 2, transition: '0.3s', '&:hover': { transform: 'translateY(-5px)', boxShadow: 6 } }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <EmojiEventsIcon sx={{ fontSize: 48, color: '#FFD700', mb: 1 }} />
                <Typography variant="h5" component="div" sx={{ fontWeight: 'bold' }}>
                  {highestScore}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Highest Score
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <Card elevation={2} sx={{ height: '100%', borderRadius: 2, transition: '0.3s', '&:hover': { transform: 'translateY(-5px)', boxShadow: 6 } }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <TrendingUpIcon sx={{ fontSize: 48, color: '#4CAF50', mb: 1 }} />
                <Typography variant="h5" component="div" sx={{ fontWeight: 'bold' }}>
                  {average}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Average Score
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <Card elevation={2} sx={{ height: '100%', borderRadius: 2, transition: '0.3s', '&:hover': { transform: 'translateY(-5px)', boxShadow: 6 } }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <AssignmentIcon sx={{ fontSize: 48, color: '#2196F3', mb: 1 }} />
                <Typography variant="h5" component="div" sx={{ fontWeight: 'bold' }}>
                  {totalQuestions}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Total Attempts
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <Card elevation={2} sx={{ height: '100%', borderRadius: 2, transition: '0.3s', '&:hover': { transform: 'translateY(-5px)', boxShadow: 6 } }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <AccessTimeIcon sx={{ fontSize: 48, color: '#FF5722', mb: 1 }} />
                <Typography variant="h5" component="div" sx={{ fontWeight: 'bold' }}>
                  {questionStats.easy + questionStats.medium + questionStats.hard}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Problems Solved
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* Problem Difficulty Breakdown */}
        <Paper elevation={2} sx={{ p: 3, mb: 4, borderRadius: 2 }}>
          <Typography variant="h6" gutterBottom align="center">
            Problems Solved by Difficulty
          </Typography>
          <Box sx={{ display: 'flex', justifyContent: 'space-around', mt: 2 }}>
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="h4" sx={{ color: '#4CAF50', fontWeight: 'bold' }}>
                {questionStats.easy}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Easy
              </Typography>
            </Box>
            <Divider orientation="vertical" flexItem />
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="h4" sx={{ color: '#FF9800', fontWeight: 'bold' }}>
                {questionStats.medium}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Medium
              </Typography>
            </Box>
            <Divider orientation="vertical" flexItem />
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="h4" sx={{ color: '#F44336', fontWeight: 'bold' }}>
                {questionStats.hard}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Hard
              </Typography>
            </Box>
          </Box>
        </Paper>

        {/* Recent Activity */}
        <Paper elevation={2} sx={{ p: 3, borderRadius: 2 }}>
          <Typography variant="h6" gutterBottom align="center" sx={{ mb: 3 }}>
            Recent Activity
          </Typography>
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', mb: 3 }}>
            <FormControl sx={{ minWidth: 200 }}>
              <InputLabel>Time Period</InputLabel>
              <Select
                value={filter}
                label="Time Period"
                onChange={e => setFilter(e.target.value)}
                size="small"
              >
                <MenuItem value="all">All Time</MenuItem>
                <MenuItem value="month">This Month</MenuItem>
                <MenuItem value="week">This Week</MenuItem>
              </Select>
            </FormControl>
          </Box>
          
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f0f4ff' }}>
                <TableCell align="center">Date</TableCell>
                <TableCell align="center">Time</TableCell>
                <TableCell align="center">Questions Attempted</TableCell>
                <TableCell align="center">Score</TableCell>
                <TableCell align="center">Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {displayed.length > 0 ? displayed.map((r, idx) => {
                // Mock data for questions attempted - replace with actual data when available
                const questionsAttempted = Math.floor(Math.random() * 10) + 5;
                const totalQuestions = Math.floor(Math.random() * 5) + questionsAttempted;
                
                return (
                  <TableRow key={idx} sx={{ '&:nth-of-type(odd)': { bgcolor: 'rgba(0, 0, 0, 0.02)' } }}>
                    <TableCell align="center">{r.date}</TableCell>
                    <TableCell align="center">{r.time}</TableCell>
                    <TableCell align="center">
                      <Typography variant="body2">
                        {questionsAttempted} / {totalQuestions}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {Math.round(questionsAttempted/totalQuestions * 100)}% completion
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Typography variant="body2" fontWeight="bold">
                        {r.score}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        out of 100
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Box 
                        sx={{ 
                          bgcolor: r.score > 70 ? '#4CAF50' : r.score > 40 ? '#FF9800' : '#F44336', 
                          color: 'white',
                          borderRadius: 1,
                          px: 1,
                          py: 0.5,
                          display: 'inline-block',
                          minWidth: '100px'
                        }}
                      >
                        {r.score > 70 ? 'Excellent' : r.score > 40 ? 'Good' : 'Needs Improvement'}
                      </Box>
                    </TableCell>
                  </TableRow>
                );
              }) : (
                <TableRow>
                  <TableCell colSpan={5} align="center">No activity found for the selected period</TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </Paper>
      </Container>
    </Box>
  );
};

export default Performance;
