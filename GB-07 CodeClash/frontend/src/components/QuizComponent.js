"use client"

import { useState, useEffect, useRef } from "react"
import "../styling/QuizStyles.css"
import { Clock, Trophy, CheckCircle, XCircle, Menu, X, User, ChevronDown, Check } from "lucide-react"
import Navbar2 from "../components/Navbar2"
// Import your question data here
import { btechCSQuestions } from "../data/questions/btech-cs-questions";
import { btechQuestions } from "../data/questions/btech-questions";
import { generalKnowledgeQuestions } from "../data/questions/general-knowledge-questions";
import { logicalQuestions } from "../data/questions/logical-questions";
import { technicalQuestions } from "../data/questions/technical-questions";

const QUESTION_TYPES = [
  { label: "MCA", value: "btechCSQuestions" },
  { label: "BTech General", value: "btechQuestions" },
  { label: "General Knowledge", value: "generalKnowledgeQuestions" },
  { label: "Logical Reasoning", value: "logicalQuestions" },
  { label: "Technical", value: "technicalQuestions" },
]

// Mock questions for demonstration - replace with your actual imports
const QUESTIONS_MAP = {
  btechCSQuestions,
  btechQuestions,
  generalKnowledgeQuestions,
  logicalQuestions,
  technicalQuestions,
}

function shuffle(arr) {
  return [...arr]
    .map((v) => [Math.random(), v])
    .sort((a, b) => a[0] - b[0])
    .map((a) => a[1])
}

// Simple toast notification system
const Toast = ({ message, type, onClose }) => {
  useEffect(() => {
    const timer = setTimeout(() => {
      onClose()
    }, 3000)
    return () => clearTimeout(timer)
  }, [onClose])

  return (
    <div className={`toast ${type}`}>
      <div className="toast-content">
        <p>{message}</p>
      </div>
      <button className="toast-close" onClick={onClose}>
        <X size={16} />
      </button>
    </div>
  )
}


// Select Component
const Select = ({ label, value, onChange, options }) => {
  const [isOpen, setIsOpen] = useState(false)
  const selectRef = useRef(null)

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (selectRef.current && !selectRef.current.contains(event.target)) {
        setIsOpen(false)
      }
    }

    document.addEventListener("mousedown", handleClickOutside)
    return () => {
      document.removeEventListener("mousedown", handleClickOutside)
    }
  }, [])

  const selectedOption = options.find((option) => option.value === value)

  return (
    <div className="select-container" ref={selectRef}>
      <label className="select-label">{label}</label>
      <button type="button" className="select-trigger" onClick={() => setIsOpen(!isOpen)}>
        <span>{selectedOption ? selectedOption.label : "Select..."}</span>
        <ChevronDown size={16} />
      </button>

      {isOpen && (
        <div className="select-content">
          {options.map((option) => (
            <div
              key={option.value}
              className={`select-item ${value === option.value ? "selected" : ""}`}
              onClick={() => {
                onChange(option.value)
                setIsOpen(false)
              }}
            >
              {value === option.value && <Check size={16} className="select-item-check" />}
              <span>{option.label}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

// Main Quiz Component
function QuizComponent() {
  const [questionType, setQuestionType] = useState(QUESTION_TYPES[0].value)
  const [numQuestions, setNumQuestions] = useState(10)
  const [questions, setQuestions] = useState([])
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0)
  const [selectedAnswer, setSelectedAnswer] = useState("")
  const [score, setScore] = useState(0)
  const [quizStarted, setQuizStarted] = useState(false)
  const [quizFinished, setQuizFinished] = useState(false)
  const [timeLeft, setTimeLeft] = useState(10)
  const timerRef = useRef(null)
  const [shuffledAnswers, setShuffledAnswers] = useState([])
  const [resultSaved, setResultSaved] = useState(false)
  const [saving, setSaving] = useState(false)
  const [toast, setToast] = useState(null)

  useEffect(() => {
    if (quizStarted && questions.length > 0) {
      setShuffledAnswers(
        shuffle([...(questions[currentQuestionIndex].options || questions[currentQuestionIndex].answers || [])]),
      )
      setTimeLeft(10)
      setSelectedAnswer("")
    }
  }, [quizStarted, currentQuestionIndex, questions])

  useEffect(() => {
    if (!quizStarted || quizFinished) return
    if (timeLeft > 0) {
      timerRef.current = setTimeout(() => setTimeLeft(timeLeft - 1), 1000)
    } else {
      handleNextQuestion()
    }
    return () => clearTimeout(timerRef.current)
  }, [quizStarted, quizFinished, timeLeft])

  const handleStart = () => {
    const all = QUESTIONS_MAP[questionType] || []
    const selected = shuffle(all).slice(0, Math.min(numQuestions, all.length))
    setQuestions(selected)
    setCurrentQuestionIndex(0)
    setScore(0)
    setQuizFinished(false)
    setQuizStarted(true)
    setResultSaved(false)
  }

  const handleAnswer = (ans) => {
    setSelectedAnswer(ans)
    if (
      ans === questions[currentQuestionIndex].correctAnswer ||
      ans === questions[currentQuestionIndex].correct_answer
    ) {
      setScore((s) => s + 1)
    }
    setTimeout(() => handleNextQuestion(), 800)
  }

  const handleNextQuestion = () => {
    if (currentQuestionIndex < questions.length - 1) {
      setCurrentQuestionIndex((i) => i + 1)
    } else {
      setQuizFinished(true)
      setQuizStarted(false)
    }
  }

  const handleRestart = () => {
    setQuizStarted(false)
    setQuizFinished(false)
    setQuestions([])
    setCurrentQuestionIndex(0)
    setScore(0)
    setTimeLeft(10)
    setSelectedAnswer("")
    setResultSaved(false)
  }

  const showToast = (message, type = "success") => {
    setToast({ message, type })
  }

  const closeToast = () => {
    setToast(null)
  }

  useEffect(() => {
    if (quizFinished && !resultSaved && questions.length > 0) {
      setSaving(true)
      const username = localStorage.getItem("Username") || "anonymous"
      const now = new Date()
      const date = now.toISOString().split("T")[0]
      const time = now.toTimeString().split(" ")[0]
      const finalScore = score

      // Uncomment this for actual API call
      
      fetch('http://localhost:8788/api/quiz/saveResult', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, score: finalScore, date, time, No_of_questions: questions.length })
      })
        .then(res => res.text())
        .then(text => {
          setResultSaved(true);
          setSaving(false);
          showToast(`Your score of ${finalScore}/${questions.length} has been saved.`);
        })
        .catch(() => {
          setSaving(false);
          showToast("There was a problem saving your quiz result.", "error");
        });
      

      // Simulate API call (replace with your actual API endpoint)
      setTimeout(() => {
        setSaving(false)
        setResultSaved(true)
        showToast(`Your score of ${finalScore}/${questions.length} has been saved.`)
      }, 1000)
    }
  }, [quizFinished, resultSaved, questions, score])

  const progressPercentage = quizStarted ? ((currentQuestionIndex + 1) / questions.length) * 100 : 0
  const timePercentage = (timeLeft / 10) * 100

  return (
    <div className="quiz-app">
      <Navbar2 />

      <main className="quiz-container">
        <h1 className="quiz-title">Test Your Knowledge</h1>

        {!quizStarted && !quizFinished && (
          <div className="quiz-card setup-card">
            <div className="card-accent"></div>
            <div className="card-content">
              <h2 className="card-title">Select Quiz Options</h2>

              <div className="form-group">
                <Select
                  label="Question Type"
                  value={questionType}
                  onChange={setQuestionType}
                  options={QUESTION_TYPES}
                />
              </div>

              <div className="form-group">
                <Select
                  label="Number of Questions"
                  value={numQuestions.toString()}
                  onChange={(value) => setNumQuestions(Number(value))}
                  options={[5, 10, 15, 20].map((n) => ({ label: n.toString(), value: n.toString() }))}
                />
              </div>

              <button className="start-button" onClick={handleStart}>
                Start Quiz
              </button>
            </div>
          </div>
        )}

        {quizStarted && !quizFinished && questions.length > 0 && (
          <div className="quiz-card question-card">
            <div className="card-accent"></div>
            <div className="card-content">
              <div className="question-header">
                <div className="question-counter">
                  <span className="question-number">{currentQuestionIndex + 1}</span>
                  <span className="question-total">of {questions.length}</span>
                </div>
                <div className="score-badge">
                  <span>Score: {score}</span>
                </div>
              </div>

              <div className="progress-bar">
                <div className="progress-fill" style={{ width: `${progressPercentage}%` }}></div>
              </div>

              <div className="question-content">
                <h3 className="question-text">{questions[currentQuestionIndex].question}</h3>

                <div className="answer-options">
                  {shuffledAnswers.map((answer, index) => {
                    const isCorrect =
                      selectedAnswer &&
                      (answer === questions[currentQuestionIndex].correctAnswer ||
                        answer === questions[currentQuestionIndex].correct_answer)
                    const isSelected = selectedAnswer === answer
                    const isWrong = isSelected && !isCorrect

                    return (
                      <div
                        key={index}
                        className={`answer-option ${isSelected ? "selected" : ""} ${
                          isCorrect ? "correct" : isWrong ? "incorrect" : ""
                        }`}
                        onClick={() => !selectedAnswer && handleAnswer(answer)}
                      >
                        <div className="radio">
                          <div className="radio-dot"></div>
                        </div>
                        <span className="answer-text">{answer}</span>
                        {isCorrect && <CheckCircle className="answer-icon correct" />}
                        {isWrong && <XCircle className="answer-icon incorrect" />}
                      </div>
                    )
                  })}
                </div>
              </div>

              <div className="timer">
                <Clock className="timer-icon" />
                <div className="timer-bar">
                  <div className="timer-fill" style={{ width: `${timePercentage}%` }}></div>
                </div>
                <span className="timer-text">{timeLeft}s</span>
              </div>

              <p className="timer-hint">Auto-advancing to next question in {timeLeft} seconds</p>
            </div>
          </div>
        )}

        {quizFinished && (
          <div className="quiz-card result-card">
            <div className="card-accent"></div>
            <div className="card-content">
              <div className="trophy-container">
                <Trophy className="trophy-icon" />
              </div>

              <h2 className="result-title">Quiz Completed!</h2>

              <div className="result-score">
                <p className="score-value">
                  {score} / {questions.length}
                </p>
                <p className="score-percentage">{Math.round((score / questions.length) * 100)}% Correct</p>
              </div>

              {saving && <p className="saving-text">Saving your results...</p>}

              <button className="restart-button" onClick={handleRestart}>
                Try Again
              </button>
            </div>
          </div>
        )}
      </main>

      {toast && <Toast message={toast.message} type={toast.type} onClose={closeToast} />}
    </div>
  )
}

export default QuizComponent
