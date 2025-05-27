"use client"

import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import Navbar2 from "./Navbar2";
import Editor from "@monaco-editor/react";
import problems from "../data/problems.json";

export default function PracticePage() {
  const location = useLocation()
  const navigate = useNavigate()
  const [problem, setProblem] = useState(null)
  const [code, setCode] = useState("")
  const [language, setLanguage] = useState("java")
  const [output, setOutput] = useState("")
  const [isRunning, setIsRunning] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [testResults, setTestResults] = useState([])
  const [testCaseIndex, setTestCaseIndex] = useState(0)
  const [testCaseOutput, setTestCaseOutput] = useState("")
  const [testCasePassed, setTestCasePassed] = useState(false)
  const [testCaseInput, setTestCaseInput] = useState("")
  const [currentTestCase, setCurrentTestCase] = useState(null)
  const input = problem?.testCases?.map(tc => tc.input) || ""

  // Function to run a single test case
  const runSingleTestCase = async (testCase) => {
    if (!problem || !testCase) {
      toast.error('No test case selected');
      return;
    }
    
    setIsRunning(true);
    setCurrentTestCase(testCase);

    try {
      const token = sessionStorage.getItem("Authtoken");
      if (!token) {
        throw new Error("Unauthorized");
      }

      const response = await fetch("http://localhost:8788/api/coderun", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify({
          className: "Solution",
          code: code,
          input: testCase.input
        }),
      });

      const rawOutput = (await response.text()).trim();
      // Normalize line endings and trim
      const actualOutput = rawOutput.replace(/\r\n/g, '\n').trim();
      const expectedOutput = (testCase.output || '').replace(/\r\n/g, '\n').trim();
      
      // Debug log
      console.log('Actual:', JSON.stringify(actualOutput));
      console.log('Expected:', JSON.stringify(expectedOutput));
      
      // Optionally, ignore all whitespace differences
      // const normalize = str => str.replace(/\s+/g, ' ').trim();
      // const isPassed = normalize(actualOutput) === normalize(expectedOutput);
      const isPassed = actualOutput === expectedOutput;
      
      // Update test results
      setTestResults(prevResults => [...prevResults, {
        testCase,
        output: actualOutput,
        passed: isPassed
      }]);

      // Update current test case result
      setTestCaseOutput(actualOutput);
      setTestCasePassed(isPassed);
      
      if (isPassed) {
        toast.success('Test case passed!');
      } else {
        toast.error('Test case failed');
      }
    } catch (error) {
      toast.error('Error running test case');
      console.error(error);
    } finally {
      setIsRunning(false);
    }
  };

  // Default starter code templates for different languages
  const starterCodeTemplates = {
    java: `class Solution {
}`
  }

  // Add this mapping at the top of your file or before the runCode function
  const languageIdMapping = {
    java: 62,
  };

  useEffect(() => {
    // Get problem from location state or redirect back to problem list
    const problemId = location.state?.problemId;
    if (!problemId) {
      navigate('/problems');
      return;
    }

    // Find the problem in problems.json
    const selectedProblem = problems.find(p => p.title === problemId);
    if (selectedProblem) {
      setProblem(selectedProblem);
      // Set initial starter code based on selected language
      setCode(starterCodeTemplates[language] || '');
    } else {
      toast.error('Problem not found');
      navigate('/problems');
    }
  }, [location, navigate, language])

  // Change language and update starter code
  const handleLanguageChange = (newLanguage) => {
    setLanguage(newLanguage)
    setCode(starterCodeTemplates[newLanguage])
  }

  // Mock function to run code (in a real app, this would send code to a backend)
  const runCode = async () => {
    console.log(code);
    console.log(input);
    setOutput("")
    try {
      const token = sessionStorage.getItem("Authtoken")
      // console.log(token);
      if (!token) throw new Error("Unauthorized")
      const response = await fetch("http://localhost:8788/api/coderun", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify({
          className:"Solution",
          code,
          input:input[testCaseIndex],
          
        }),
      });
      const output = (await response.text()).trim();
      setOutput(output);
      console.log(output);
    } catch (error) {
      toast.error('Error running code');
      console.error(error);
    } finally {
      setIsRunning(false);
    }
  };

  const handleCodeChange = (newCode) => {
    setCode(newCode)
  }

  // Mock function to submit and test code
  const submitCode = async () => {
    if (!problem) {
      toast.error('No problem selected');
      return;
    }
    console.log(code);
    console.log(language);
    console.log(problem.title);
    console.log(problem.category);
    console.log(testResults.filter(r => r.passed).length);

    setIsSubmitting(true);

    try {
      const token = sessionStorage.getItem('Authtoken');
      const response = await fetch(`http://localhost:8788/api/submit`, {
        method: 'POST',
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          title: problem.title,
          category: problem.category,
          code: code,
          language: language,
          testCasesPassed: testResults.filter(r => r.passed).length
        })
      });

      const result = await response.json();

      if (result) {
        toast.success('Code submitted successfully!');
        // Additional logic for successful submission
      } else {
        toast.error(result.message || 'Submission failed');
      }
    } catch (error) {
      toast.error('Error submitting code');
      console.error(error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const testCode = () => {
    setIsSubmitting(true)
    setTestResults([])

    // Simulate code testing delay
    setTimeout(() => {
      // Mock test results
      const results = problem.testCases.map((testCase, index) => {
        // In a real app, you would actually run the code against the test cases
        const passed = Math.random() > 0.3 // Random pass/fail for demo
        return {
          testCase,
          passed,
          output: passed ? testCase.output : "Wrong output",
        }
      })

      setTestResults(results)
      setIsSubmitting(false)
    }, 1500)
  }

  if (!problem) {
    return <div>Loading...</div>
  }



  return (
    <div className="min-h-screen bg-[#1e1e1e] text-gray-200 flex flex-col">
      <Navbar2 />

      <div className="flex-1 flex flex-col md:flex-row">
        {/* Problem Description Panel */}
        <div className="md:w-1/2 p-4 overflow-y-auto border-r border-gray-700">
          <div className="max-w-2xl mx-auto">
            <h1 className="text-2xl font-bold mb-4">{problem.title}</h1>

            <div className="prose prose-invert max-w-none">
              <div className="mb-6" dangerouslySetInnerHTML={{ __html: problem.description }} />

              <div className="mb-4">
                <p>
                  <strong>Category:</strong> {problem.category}
                </p>
                <p>
                  <strong>Input Format:</strong> {problem.inputFormat}
                </p>
                <p>
                  <strong>Output Format:</strong> {problem.outputFormat}
                </p>
                <p>
                  <strong>Constraints:</strong> {problem.constraints}
                </p>
              </div>

              <h4 className="font-semibold mt-6 mb-3">Test Cases:</h4>
              <div className="space-y-4">
                {problem.testCases.slice(0, 2).map((tc, i) => (
                  <div key={i} className="bg-[#252525] p-4 rounded-md">
                    <div className="mb-2">
                      <span className="font-mono font-bold">Input:</span>
                      <code className="ml-2 bg-[#333] px-2 py-1 rounded font-mono">{tc.input}</code>
                    </div>
                    <div>
                      <span className="font-mono font-bold">Output:</span>
                      <code className="ml-2 bg-[#333] px-2 py-1 rounded font-mono">{tc.output}</code>
                    </div>
                  </div>
                ))}
              </div>

              {problem.testCases.length > 2 && (
                <div className="mt-4 text-gray-400 italic">
                  {problem.testCases.length - 2} more test cases are hidden
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Code Editor Panel */}
        <div className="md:w-1/2 flex flex-col">
          {/* Editor Controls */}
          <div className="bg-[#252525] p-3 border-b border-gray-700 flex items-center">
            <select
              value={language}
              onChange={(e) => handleLanguageChange(e.target.value)}
              className="bg-[#333] text-gray-200 px-3 py-1 rounded mr-4 border border-gray-600"
            >
              <option value="java">Java</option>
            </select>

            <button
              onClick={() => {
                if (problem && problem.testCases && problem.testCases.length > 0) {
                  runSingleTestCase(problem.testCases[testCaseIndex]);
                }
              }}
              disabled={isRunning || !problem?.testCases?.length}
              className="px-4 py-1 bg-blue-600 text-white rounded mr-2 hover:bg-blue-700 disabled:opacity-50"
            >
              {isRunning ? "Running..." : "Run Test Case"}
            </button>

            <button
              onClick={() => {
                if (testCaseIndex < problem?.testCases?.length - 1) {
                  setTestCaseIndex(testCaseIndex + 1);
                  setCurrentTestCase(null);
                }
              }}
              disabled={testCaseIndex >= problem?.testCases?.length - 1}
              className="px-4 py-1 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50"
            >
              Next Test Case
            </button>

            <span className="ml-4 text-sm text-gray-400">
              {testCaseIndex + 1}/{problem?.testCases?.length || 0} test cases
            </span>

            <button
              onClick={submitCode}
              disabled={isSubmitting}
              className="px-4 py-1 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50"
            >
              {isSubmitting ? "Submitting..." : "Submit"}
            </button>
          </div>

          {/* Code Editor */}
          <div style={{ height: '500px', width: '100%' }}>
            <Editor
              height="100%"
              width="100%"
              language={language}
              value={code}
              onChange={handleCodeChange}
              theme="vs-dark"
              options={{
                minimap: { enabled: false },
                fontSize: 14,
                scrollBeyondLastLine: false,
                automaticLayout: true,
                tabSize: 2,
              }}
            />
          </div>

          {/* Output/Results Panel */}
          <div className="h-1/3 bg-[#252525] overflow-y-auto border-t border-gray-700">
            <div className="p-4">
              {/* Console Output Tab */}
              {output && (
                <div>
                  <h3 className="text-sm font-semibold mb-2 text-gray-400">Console Output:</h3>
                  <pre className="bg-[#1e1e1e] p-3 rounded font-mono text-sm whitespace-pre-wrap">{output}</pre>
                </div>
              )}

              {/* Current Test Case */}
              {currentTestCase && (
                <div className="mt-4">
                  <h3 className="text-sm font-semibold mb-2 text-gray-400">Current Test Case:</h3>
                  <div className="space-y-2">
                    <div className="p-2 rounded flex items-start">
                      <div className="mr-2 font-bold text-gray-400">Input:</div>
                      <div className="flex-1">
                        <code className="font-mono text-gray-400">{currentTestCase.input}</code>
                      </div>
                    </div>
                    <div className="p-2 rounded flex items-start">
                      <div className="mr-2 font-bold text-gray-400">Expected Output:</div>
                      <div className="flex-1">
                        <code className="font-mono text-gray-400">{currentTestCase.output}</code>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Test Results Tab */}
              {testResults.length > 0 && (
                <div className="mt-4">
                  <h3 className="text-sm font-semibold mb-2 text-gray-400">Test Results:</h3>
                  <div className="space-y-2">
                    {testResults.map((result, idx) => (
                      <div
                        key={idx}
                        className={`p-2 rounded flex items-start ${result.passed
                            ? "bg-green-900/20 border border-green-800"
                            : "bg-red-900/20 border border-red-800"
                          }`}
                      >
                        <div className={`mr-2 font-bold ${result.passed ? "text-green-500" : "text-red-500"}`}>
                          {result.passed ? "✓" : "✗"}
                        </div>
                        <div className="flex-1">
                          <div className="text-sm">
                            <span className="font-mono">Input: </span>
                            <span className="font-mono text-gray-400">{result.testCase.input}</span>
                          </div>
                          <div className="text-sm">
                            <span className="font-mono">Expected: </span>
                            <span className="font-mono text-gray-400">{result.testCase.output}</span>
                          </div>
                          <div className="text-sm">
                            <span className="font-mono">Output: </span>
                            <span className="font-mono text-gray-400">{result.output}</span>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="mt-4 text-center">
                    <span
                      className={`font-bold ${testResults.every((r) => r.passed) ? "text-green-500" : "text-red-500"}`}
                    >
                      {testResults.filter((r) => r.passed).length}/{testResults.length} tests passed
                    </span>
                  </div>
                </div>
              )}

              {!currentTestCase && !testResults.length && (
                <div className="text-gray-500 italic">Run a test case to see results here</div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}