import axios from 'axios';
import { toast } from 'react-toastify';

const API_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8080';

export const CodeExecutorService = {
  async executeCode(code, language, input = '') {
    try {
      const response = await axios.post(`${API_URL}/api/execute`, {
        code,
        language,
        input
      });
      return response.data;
    } catch (error) {
      toast.error('Code execution failed');
      console.error('Code execution error:', error);
      throw error;
    }
  },

  async runTestCases(code, language, testCases) {
    try {
      const testResults = await Promise.all(
        testCases.map(async (testCase) => {
          const result = await this.executeCode(code, language, testCase.input);
          return {
            testCase,
            passed: result.output.trim() === testCase.output.trim(),
            output: result.output
          };
        })
      );
      return testResults;
    } catch (error) {
      toast.error('Test case execution failed');
      console.error('Test case execution error:', error);
      throw error;
    }
  }
};
