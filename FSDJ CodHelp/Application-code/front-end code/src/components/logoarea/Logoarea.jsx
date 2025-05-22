    import React from "react";
    import logoforapp from "../../assets/hellologo5.gif";
    import "./Logo.css";

    const Logoarea = () => {
    return (
        <>
        <div className="d-flex flex-wrap justify-between items-center bg-gray-600 p-2 rounded-lg HelloCodersLogo">
            <div className="leftcontainer d-flex flex-wrap items-center">
            <img src={logoforapp} className="img-fluid" alt="Roadmap Builder" style={{mixBlendMode:"multiply"}} />
            <h1 className="font-sens font-bold text-light text-ligth text-lg text-center text-capitalize text-wrap">
                codHelp
            </h1>
            </div>
            <div className="rightcontainer">
            <p className="mr-2 text-light text-md">
                Built by{" "}
                <span className="font-semibold text-blue-400">
                Vikas Singh Team
                </span>
                <details className="">
                <summary>Team Members</summary>
                <ul className="right-8 z-50 absolute bg-gray-700 shadow-lg mt-2 p-2 rounded-md w-58">
                    <li className="font-semibold text-blue-400">😊 Vikas Singh</li>
                    <li className="font-semibold text-blue-400">🤦‍♀️ Vanshika Tyagi</li>
                    <li className="font-semibold text-blue-400">
                    😠 Vaibhav Singh Kalura
                    </li>
                    <li className="font-semibold text-blue-400">🤪 Tushar Kumar</li>
                </ul>
                </details>
            </p>
            </div>
        </div>
        </>
    );
    };

    export default Logoarea;
