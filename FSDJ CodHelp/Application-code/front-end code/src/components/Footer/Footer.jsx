    import React from "react";
    import { FaGlobe, FaHeart } from "react-icons/fa";

    export default function Footer() {
    const currentYear = new Date().getFullYear();

    return (
        <footer className="bg-gray-950 mt-12 py-6 text-white">
        <div className="mx-auto text-center container">
            {/* <p className="text-gray-400 text-sm">
            Built with <FaHeart className="inline mx-1 text-red-500" /> by <span className="font-semibold text-blue-400">Vikas Singh Team</span>
            </p> */}

            {/* <p className="mt-2 btn btn-sm btn-primary">
            <a
                style={{ textDecoration: "none", color: "white" }}z
                href="https://myportfoliobyvikassingh.netlify.app"
                target="_blank"
                rel="noopener noreferrer"
                className="flex justify-center items-center space-x-2 text-blue-500 hover:text-blue-300"
            >
                <FaGlobe className="text-xl" />
                <span>Visit My Portfolio</span>
            </a>
            </p> */}

            <p className="mt-3 text-gray-500 text-sm">
            © {currentYear} codHelp. All rights reserved.
            </p>
        </div>
        </footer>
    );
    }
