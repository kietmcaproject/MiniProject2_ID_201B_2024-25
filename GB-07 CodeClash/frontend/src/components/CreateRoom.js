import React from "react";
import Navbar2 from "./Navbar2";
import QuizComponent from "./QuizComponent";

const CreateRoom = () => (
  <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-indigo-50">
    <Navbar2 />
    <div className="container mx-auto px-4 py-12">
      <QuizComponent />
    </div>
  </div>
);

export default CreateRoom;
