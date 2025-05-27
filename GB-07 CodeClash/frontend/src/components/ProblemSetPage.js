"use client"

import { useState } from "react"
import { useNavigate } from 'react-router-dom';
import Navbar2 from "./Navbar2"
import problems from "../data/problems.json"

const allCategories = ["All", ...new Set(problems.map((p) => p.category))]

export default function ProblemSetPage() {
  const [categoryFilter, setCategoryFilter] = useState("All")
  const [selected, setSelected] = useState(null)
  const navigate = useNavigate();
  const filtered = categoryFilter === "All" ? problems : problems.filter((p) => p.category === categoryFilter)

  return (
    <div className="min-h-screen bg-[#1e1e1e] text-gray-200">
      <Navbar2 />
      <div className="p-8 max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold">Problem List</h2>
          <div>
            <label className="mr-2">Category:</label>
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="bg-[#2d2d2d] border border-gray-700 p-2 rounded text-gray-200"
            >
              {allCategories.map((cat) => (
                <option key={cat} value={cat}>
                  {cat}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Problem List */}
          <div className="md:col-span-1">
            <ul className="space-y-2">
              {filtered.map((p, idx) => (
                <li key={idx} className="p-2 hover:bg-[#2d2d2d] rounded transition-colors">
                  <button onClick={() => setSelected(p)} className="text-blue-400 hover:text-blue-300 text-left w-full">
                    {p.title}
                  </button>
                </li>
              ))}
            </ul>
          </div>

          {/* Problem Details */}
          <div className="md:col-span-2">
            {selected && (
              <div className="p-6 bg-[#2d2d2d] rounded-lg">
                <h3 className="text-xl font-bold mb-4">{selected.title}</h3>

                <div className="prose prose-invert max-w-none">
                  <div className="mb-6" dangerouslySetInnerHTML={{ __html: selected.description }} />

                  <div className="mb-4">
                    <p>
                      <strong>Category:</strong> {selected.category}
                    </p>
                    <p>
                      <strong>Input Format:</strong> {selected.inputFormat}
                    </p>
                    <p>
                      <strong>Output Format:</strong> {selected.outputFormat}
                    </p>
                    <p>
                      <strong>Constraints:</strong> {selected.constraints}
                    </p>
                  </div>

                  <h4 className="font-semibold mt-6 mb-3">Test Cases:</h4>
                  <div className="space-y-4">
                    {selected.testCases.slice(0, 2).map((tc, i) => (
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

                  {selected.testCases.length > 2 && (
                    <div className="mt-4 text-gray-400 italic">
                      {selected.testCases.length - 2} more test cases are hidden
                    </div>
                  )}
                  <button
                    onClick={() => navigate('/practicepage', { state: { problemId: selected.title} })}
                    className="mt-4 px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 transition"
                  >
                    Solve
                  </button>
                </div>
              </div>
            )}

            {!selected && (
              <div className="flex items-center justify-center h-full p-10 bg-[#2d2d2d] rounded-lg">
                <p className="text-gray-400">Select a problem to view details</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
