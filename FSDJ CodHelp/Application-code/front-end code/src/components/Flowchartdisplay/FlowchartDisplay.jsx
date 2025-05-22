import React, { useState, useCallback, useEffect } from "react";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { FaSearch, FaBars, FaTimes } from "react-icons/fa";
import { motion } from "framer-motion"; // Import framer-motion
import Logoarea from "../logoarea/Logoarea";
import Navbar from "../navbar/Navbar";
import ReactFlow, {
    MiniMap,
    Controls,
    Background,
    applyNodeChanges,
    applyEdgeChanges,
    addEdge,
    ReactFlowProvider,
} from "reactflow";
import "reactflow/dist/style.css";
import "./FlowchartDisplay.css";
import { useLocation } from "react-router-dom";

const API_KEY = import.meta.env.VITE_GENERATIVE_AI_API_KEY;

const FlowchartDisplay = () => {
    const [searchTerm, setSearchTerm] = useState("");
    const [nodes, setNodes] = useState([]);
    const [edges, setEdges] = useState([]);
    const [summary, setSummary] = useState("");
    const [cleanDetails, setCleanDetails] = useState("");
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [importExportVisible, setImportExportVisible] = useState(true); // State to toggle sidebar visibility
    const location = useLocation();

    useEffect(() => {
        const params = new URLSearchParams(location.search);
        const search = params.get("search");
        if (search) {
            setSearchTerm(search);
            handleSearch(search);
        }
    }, [location]);

    const toggleSidebar = () => setSidebarOpen(!sidebarOpen);

    const toggleImportExportVisibility = () => {
        setImportExportVisible(!importExportVisible);
    };

    const handleSearch = async (term) => {
        if (!term) return;

        setLoading(true);
        setError(null);

        try {
            const genAI = new GoogleGenerativeAI(API_KEY);
            const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

            const roadmapPrompt = `Generate a structured roadmap for ${term}, listing key technologies or steps in sequential order. Including definition, importance, use cases.`;
            const summaryPrompt = `Generate a summary of ${term}.`;

            const roadmapResult = await model.generateContent(roadmapPrompt);
            const roadmapText = await roadmapResult.response.text();
            const processedData = processFlowData(roadmapText);

            setNodes(generateNodes(processedData));
            setEdges(generateEdges(processedData));

            const summaryResult = await model.generateContent(summaryPrompt);
            const summaryResponse = await summaryResult.response.text();
            setSummary(cleanGeneratedText(summaryResponse));
        } catch (err) {
            setError("Error fetching data. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    const cleanGeneratedText = (text) =>
        text.replace(/[*\-]/g, "").replace(/\s+/g, " ").trim();

    const processFlowData = (text) => {
        return text.split("\n").map((line, index) => {
            const match = line.match(/^\d+\.\s*(.+)$/);
            return { id: index.toString(), label: match ? match[1] : line };
        });
    };

    const generateNodes = (data) => {
        const colors = [
            "#ffadad",
            "#ffd6a5",
            "#fdffb6",
            "#caffbf",
            "#9bf6ff",
            "#a0c4ff",
            "#bdb2ff",
            "#ffc6ff",
        ];
        let currentX = 280,
            currentY = 280,
            toggleY = true;

        return data.map((item, index) => {
            currentX += 360;
            currentY += toggleY ? 150 : 100;
            toggleY = !toggleY;

            return {
                id: item.id,
                data: { label: item.label },
                position: { x: currentX, y: currentY },
                style: {
                    backgroundColor: colors[index % colors.length],
                    color: "#333",
                    borderRadius: "12px",
                    padding: "12px",
                    fontSize: "14px",
                    fontWeight: "bold",
                    textAlign: "left",
                    boxShadow: "2px 2px 10px rgba(0, 0, 0, 0.2)",
                    width: "200px",
                    whiteSpace: "pre-wrap",
                },
                draggable: true,
            };
        });
    };

    const generateEdges = (data) => {
        return data.slice(1).map((item, index) => ({
            id: `e${index}-${index + 1}`,
            source: data[index].id,
            target: item.id,
            animated: true,
            style: { stroke: "blue", strokeWidth: 3 }, // Updated edge style to match video node edges
        }));
    };

    const onNodesChange = useCallback(
        (changes) => {
            setNodes((nds) => {
                let updatedNodes = applyNodeChanges(changes, nds);

                // Find moved details nodes
                changes.forEach((change) => {
                    if (change.type === "position" && change.id.startsWith("details-")) {
                        const detailsNode = updatedNodes.find((n) => n.id === change.id);
                        if (!detailsNode) return;

                        // Find all video nodes connected from this details node
                        const relatedVideoNodes = updatedNodes.filter((n) => n.id.startsWith(`video-${change.id}-`));
                        relatedVideoNodes.forEach((videoNode, idx) => {
                            // Update position relative to details node
                            videoNode.position = {
                                x: detailsNode.position.x + 420 + idx * 420,
                                y: detailsNode.position.y,
                            };
                        });
                    }
                });

                return [...updatedNodes];
            });
        },
        []
    );

    const onEdgesChange = useCallback(
        (changes) => setEdges((eds) => applyEdgeChanges(changes, eds)),
        []
    );

    const onConnect = useCallback(
        (connection) => setEdges((eds) => addEdge({ ...connection, animated: true }, eds)),
        []
    );

    const handleNodeClick = async (event, node) => {
        if (node.id.startsWith("details-") || node.id.startsWith("video-")) {
            setNodes((nds) => {
                if (node.id.startsWith("details-")) {
                    // Remove the details node and all its video nodes
                    return nds.filter(
                        (n) =>
                            n.id !== node.id &&
                            !n.id.startsWith(`video-${node.id}-`)
                    );
                }
                // If deleting a video node, just remove that node
                return nds.filter((n) => n.id !== node.id);
            });
            setEdges((eds) => {
                if (node.id.startsWith("details-")) {
                    // Remove all edges connected to the details node and its video nodes
                    return eds.filter(
                        (e) =>
                            e.source !== node.id &&
                            e.target !== node.id &&
                            !e.id.startsWith(`e${node.id}-video-`) &&
                            !e.source.startsWith(`video-${node.id}-`) &&
                            !e.target.startsWith(`video-${node.id}-`)
                    );
                }
                // If deleting a video node, just remove edges connected to that node
                return eds.filter(
                    (e) => e.source !== node.id && e.target !== node.id
                );
            });
            return;
        }

        setLoading(true);

        try {
            const genAI = new GoogleGenerativeAI(API_KEY);
            const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

            const detailsPrompt = `Provide a concise explanation of ${node.data.label}, including definition, importance, use cases, and related concepts.`;
            const detailsResult = await model.generateContent(detailsPrompt);
            const detailsText = await detailsResult.response.text();
            const cleanedDetails = cleanGeneratedText(detailsText);

            const colors = [
                "#ffadad",
                "#ffd6a5",
                "#fdffb6",
                "#caffbf",
                "#9bf6ff",
                "#a0c4ff",
                "#bdb2ff",
                "#ffc6ff",
            ];
            const randomColorDetails = colors[Math.floor(Math.random() * colors.length)];
            setCleanDetails(cleanedDetails);

            const newNode = {
                id: `details-${node.id}`,
                data: {
                    label: (
                        <div style={{ position: "relative"}}>
                            {cleanedDetails}
                            <FaTimes
                                style={{
                                    position: "absolute",
                                    top: "-10px",
                                    right: "-10px",
                                    cursor: "pointer",
                                    display: "none",
                                }}
                                className="delete-icon"
                            />
                        </div>
                    ),
                },
                position: { x: node.position.x - 600, y: node.position.y+600 },
                style: {
                    backgroundColor: randomColorDetails,
                    color: "#333",
                    borderRadius: "12px",
                    padding: "12px",
                    fontSize: "14px",
                    fontWeight: "bold",
                    textAlign: "left",
                    boxShadow: "2px 2px 10px rgba(0, 0, 0, 0.2)",
                    width: "400px",
                    whiteSpace: "pre-wrap",
                },
                draggable: true,
            };

            setNodes((nds) => [...nds, newNode]);
            setEdges((eds) => [
                ...eds,
                {
                    id: `e${node.id}-details`,
                    source: node.id,
                    target: newNode.id,
                    animated: true,
                    style: { stroke: "green", strokeWidth: 3 }, // Updated edge color for details node
                },
            ]);

            // Fetch YouTube video
            let topic = node.data.label;
            topic = topic.replace(/[^a-zA-Z0-9\s]/g, "").trim(); // Remove special characters and trim spaces
            topic = topic.replace(/^\d+\s*/, ""); // Remove leading numbers
            topic = topic.split(" ").slice(0, 6).join(" "); // Take the first 6 words for relevance
            const apiKey = API_KEY; // Replace with your YouTube API key
            const maxResults = 4;

            let apiUrl = `https://www.googleapis.com/youtube/v3/search?part=snippet&q=${encodeURIComponent(
                topic
            )}&type=video&maxResults=${maxResults}&key=${apiKey}`;

            let videoResponse = await fetch(apiUrl);
            let videoData = await videoResponse.json();

            // Fallback mechanism if no videos are found
            if (!videoData.items || videoData.items.length === 0) {
                console.warn(`No videos found for the topic: ${topic}. Retrying with fallback query.`);
                topic = `${topic} full course`; // Append "full course" to broaden the search
                apiUrl = `https://www.googleapis.com/youtube/v3/search?part=snippet&q=${encodeURIComponent(
                    topic
                )}&type=video&maxResults=${maxResults}&key=${apiKey}`;
                videoResponse = await fetch(apiUrl);
                videoData = await videoResponse.json();

                if (!videoData.items || videoData.items.length === 0) {
                    console.error("No videos found even with fallback query:", topic);
                    return;
                }
            }

            // Create up to 8 video nodes and edges
            const videoNodes = [];
            const videoEdges = [];
            videoData.items.slice(0, maxResults).forEach((video, idx) => {
                const videoId = video.id.videoId;
                const title = video.snippet.title;
                const description = video.snippet.description;
                const randomColorVideo = colors[Math.floor(Math.random() * colors.length)];
                const videoNodeId = `video-${node.id}-${idx}`;

                videoNodes.push({
                    id: videoNodeId,
                    data: {
                        label: (
                            <div style={{ maxWidth: "400px", borderRadius: "15px", overflow: "hidden", boxShadow: "0 4px 10px rgba(0,0,0,0.2)", margin: "10px" }}>
                                <iframe
                                    width="100%"
                                    height="215"
                                    src={`https://www.youtube.com/embed/${videoId}`}
                                    frameBorder="0"
                                    allowFullScreen
                                ></iframe>
                                <div style={{ padding: "10px" , backgroundColor: "white" }}>
                                    <h4 style={{ margin: "0 0 5px 0" }}>{title}</h4>
                                    <p style={{ margin: "0" }}>{description}</p>
                                </div>
                            </div>
                        ),
                    },
                    // Position videos horizontally, aligned vertically with the details node
                    position: { x: newNode.position.x - 420 + idx * 420, y: newNode.position.y + 900 },
                    style: {
                        backgroundColor: randomColorVideo,
                        color: "#333",
                        borderRadius: "12px",
                        padding: "12px",
                        fontSize: "14px",
                        fontWeight: "bold",
                        textAlign: "left",
                        boxShadow: "2px 2px 10px rgba(0, 0, 0, 0.2)",
                        width: "400px",
                        whiteSpace: "pre-wrap",
                    },
                    draggable: true,
                });

                videoEdges.push({
                    id: `e${newNode.id}-video-${idx}`,
                    source: newNode.id,
                    target: videoNodeId,
                    animated: true,
                    style: { stroke: "purple", strokeWidth: 3 }, // Video edge color
                });
            });

            setNodes((nds) => [...nds, ...videoNodes]);
            setEdges((eds) => [...eds, ...videoEdges]);
        } catch (err) {
            console.error("Error fetching details or video:", err);
        } finally {
            setLoading(false);
        }
    };

    const handlePaneClick = (event) => {
        event.stopPropagation();
        // Do nothing on pane click
    };

    const importFlowchart = (event) => {
        const fileReader = new FileReader();
        fileReader.onload = (e) => {
            try {
                const data = JSON.parse(e.target.result);

                // Validate nodes
                const validNodes = (data.nodes || []).map((node) => {
                    if (!node.id || !node.data || !node.position) {
                        console.warn(`Invalid node detected and skipped:`, node);
                        return null;
                    }

                    // Check if the node contains video-related data
                    if (node.id.startsWith("video-") && node.data.label?.props?.children) {
                        const iframeProps = node.data.label.props.children.find(
                            (child) => child.type === "iframe"
                        )?.props;

                        if (iframeProps?.src) {
                            return {
                                id: node.id,
                                data: {
                                    label: (
                                        <div style={{ maxWidth: "400px", borderRadius: "15px", overflow: "hidden", boxShadow: "0 4px 10px rgba(0,0,0,0.2)", margin: "10px" }}>
                                            <iframe
                                                width="100%"
                                                height="215"
                                                src={iframeProps.src}
                                                frameBorder="0"
                                                allowFullScreen
                                            ></iframe>
                                            <div style={{ padding: "10px", backgroundColor: "white" }}>
                                                <h4 style={{ margin: "0 0 5px 0" }}>{node.data.label.props.children[1]?.props?.children[0]?.props?.children || "YouTube Video"}</h4>
                                                <p style={{ margin: "0" }}>{node.data.label.props.children[1]?.props?.children[1]?.props?.children || "Imported from JSON"}</p>
                                            </div>
                                        </div>
                                    ),
                                },
                                position: node.position,
                                style: {
                                    backgroundColor: "#bdb2ff",
                                    color: "#333",
                                    borderRadius: "12px",
                                    padding: "12px",
                                    fontSize: "14px",
                                    fontWeight: "bold",
                                    textAlign: "left",
                                    boxShadow: "2px 2px 10px rgba(0, 0, 0, 0.2)",
                                    width: "400px",
                                    whiteSpace: "pre-wrap",
                                },
                                draggable: true,
                            };
                        }
                    }

                    // Extract plain text content from the label
                    const label = node.data.label;
                    const validLabel = (() => {
                        if (typeof label === "string" || typeof label === "number") {
                            return label; // Valid React child
                        } else if (React.isValidElement(label)) {
                            return ""; // Ignore React elements
                        } else if (typeof label === "object" && label.props?.children) {
                            // Extract text content from children
                            const extractText = (children) => {
                                if (typeof children === "string") return children;
                                if (Array.isArray(children)) {
                                    return children.map(extractText).join(" ");
                                }
                                if (typeof children === "object" && children.props?.children) {
                                    return extractText(children.props.children);
                                }
                                return "";
                            };
                            return extractText(label.props.children);
                        } else if (typeof label === "object") {
                            // Handle objects by converting to a string
                            return JSON.stringify(label);
                        } else {
                            return ""; // Fallback for invalid labels
                        }
                    })();

                    return {
                        id: node.id,
                        data: { ...node.data, label: validLabel },
                        position: node.position,
                        style: node.style || {}, // Ensure style exists
                        draggable: node.draggable !== undefined ? node.draggable : true, // Default to true
                    };
                }).filter(Boolean); // Remove invalid nodes

                // Validate edges
                const validEdges = (data.edges || []).map((edge) => {
                    if (!edge.id || !edge.source || !edge.target) {
                        console.warn(`Invalid edge detected and skipped:`, edge);
                        return null;
                    }
                    return {
                        id: edge.id,
                        source: edge.source,
                        target: edge.target,
                        animated: edge.animated !== undefined ? edge.animated : true, // Default to true
                        style: edge.style || { stroke: "blue", strokeWidth: 2 }, // Default style
                    };
                }).filter(Boolean); // Remove invalid edges

                setNodes(validNodes);
                setEdges(validEdges);
            } catch (error) {
                console.error("Error importing flowchart:", error);
                alert("Invalid JSON file. Please check the file and try again.");
            }
        };
        fileReader.readAsText(event.target.files[0]);
    };

    const exportFlowchart = () => {
        try {
            const flowchartData = JSON.stringify({ nodes, edges }, null, 2);
            const blob = new Blob([flowchartData], { type: "application/json" });
            const url = URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            const fileName = prompt("Enter a name for the exported file:");
            a.download = fileName+".json" ||"flowchart.json";
            a.click();
        } catch (error) {
            console.error("Error exporting flowchart:", error);
            alert("An error occurred while exporting the flowchart. Please try again.");
        }
    };

    useEffect(() => {
        const handleMouseOver = (event) => {
        const deleteIcon = event.target.querySelector(".delete-icon");
        if (deleteIcon) deleteIcon.style.display = "block";
        };

        const handleMouseOut = (event) => {
        const deleteIcon = event.target.querySelector(".delete-icon");
        if (deleteIcon) deleteIcon.style.display = "none";
        };

        const nodes = document.querySelectorAll(".react-flow__node");
        nodes.forEach((node) => {
        node.addEventListener("mouseover", handleMouseOver);
        node.addEventListener("mouseout", handleMouseOut);
        });

        return () => {
        nodes.forEach((node) => {
            node.removeEventListener("mouseover", handleMouseOver);
            node.removeEventListener("mouseout", handleMouseOut);
        });
        };
    }, [nodes]);

    return (
        <>
        <ReactFlowProvider>
            {/* <Logoarea /> */}
            <Navbar />
            <div className="flex flex-wrap md:flex-nowrap h-screen">
                <motion.div 
                    className={`flex flex-col justify-between bg-gray-800 p-6 w-full md:w-64 text-white ${importExportVisible ? "block" : "hidden"}`}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 0.5 }}
                >
                    <h4 className="font-bold text-xl text-capitalize">
                        Import/Export Flowchart
                    </h4>
                    <input type="file" accept="application/json" onChange={importFlowchart} />
                    <button
                        onClick={exportFlowchart}
                        className="d-flex align-items-center gap-2 mt-4 mb-4 btn-outline-primary btn"
                    >
                        <i className="bi bi-upload" /> Export
                    </button>
                    <footer className="mt-auto text-sm text-center">
                        <p>&copy; {new Date().getFullYear()} CodHelp Roadmap Builder</p>
                    </footer>
                </motion.div>

                {/* Toggle Button for Import/Export Sidebar */}
                <motion.button
                    onClick={toggleImportExportVisibility}
                    className="z-50 shadow-lg p-3 rounded-full text-white"
                    style={{
                        opacity: 1,
                    }} // Updated position styles
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 0.5 }}
                >
                    {importExportVisible ? <FaTimes size={20} /> : <FaBars size={20} />}
                </motion.button>

                <motion.div 
                    className="flex-1 bg-gray-100 p-6"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 0.5 }}
                >
                    <div className="flex md:flex-row flex-col justify-center gap-2 md:space-x-4 mb-6">
                        <input
                            type="search"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            placeholder="Search for a roadmap..."
                            className="px-4 py-2 border rounded-md focus:ring-2 focus:ring-blue-500 w-full md:w-1/3"
                        />
                        <button
                            onClick={() => handleSearch(searchTerm)}
                            className="d-flex justify-center items-center bg-blue-500 px-4 py-2 rounded-md text-white"
                        >
                            <FaSearch className="mr-2" /> Search
                        </button>
                    </div>

                    {loading && <div className="font-bold text-gray-900 text-lg text-center text-pretty">Loading...</div>}
                    {error && <div className="text-red-500">{error}</div>}

                    <div className="flowchart-container" style={{ height: "100dvh" }}>
                        <ReactFlow
                            nodes={nodes}
                            edges={edges}
                            onNodesChange={onNodesChange}
                            onEdgesChange={onEdgesChange}
                            onConnect={onConnect}
                            onNodeClick={handleNodeClick}
                            onPaneClick={handlePaneClick} // Prevent reload on pane click
                            fitView
                            panOnDrag={true} // Enable panning when dragging
                            zoomOnScroll={true} // Enable zooming with scroll
                            zoomOnPinch={true} // Enable zooming with pinch gestures
                            minZoom={0.5} // Set minimum zoom level
                            maxZoom={2} // Set maximum zoom level
                            defaultZoom={1} // Set default zoom level
                        >
                            <MiniMap
                            nodeStrokeWidth={3} 
                            nodeStrokeColo="transparent"
                            nodeColor="#000"
                            nodeBorderRadius={12}
                            />
                            <Controls />
                            <Background variant="lines" />
                        </ReactFlow>
                    </div>
                </motion.div>

                {/* Sidebar Button */}
                <motion.button
                    onClick={toggleSidebar}
                    className="top-4 right-4 z-50 fixed bg-blue-500 shadow-lg p-3 rounded-full text-white"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 0.5 }}
                >
                    {sidebarOpen ? <FaTimes size={20} /> : <FaBars size={20} />}
                </motion.button>

                {/* Right Sidebar */}
                <motion.div
                    className={`fixed top-0 right-0 h-full w-full md:w-1/4 bg-white shadow-lg transition-transform transform overflow-scroll ${
                        sidebarOpen ? "translate-x-0" : "translate-x-full"
                    }`}
                    initial={{ x: "100%" }}
                    animate={{ x: sidebarOpen ? "0%" : "100%" }}
                    transition={{ duration: 0.5 }}
                >
                    <div className="p-4">
                        <motion.section 
                            style={{ backgroundColor: "#caffbf", padding: "1rem", borderRadius: "12px" }}
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            transition={{ duration: 0.5 }}
                        >
                            <h2 className="mb-4 font-bold text-2xl">
                                Details about the selected node
                            </h2>
                            <p className="text-gray-600">
                                {loading && "Loading..."}
                                <br />
                                {cleanDetails || "Click a Node to see details"}
                            </p>
                        </motion.section>
                        <br />
                        <motion.section 
                            style={{ backgroundColor: "#9bf6ff", padding: "1rem", borderRadius: "12px" }}
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            transition={{ duration: 0.5 }}
                        >
                            <h2 className="mb-4 font-bold text-2xl">
                                {searchTerm || "Summary"}
                            </h2>
                            <p className="text-gray-600">
                                {loading && "Loading..."}
                                <br />
                                {summary || "No summary available"}
                            </p>
                        </motion.section>
                    </div>
                </motion.div>
            </div>
        </ReactFlowProvider>
        </>
    );
};

export default FlowchartDisplay;
