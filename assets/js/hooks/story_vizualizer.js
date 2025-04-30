const StoryVisualizer = {
    mounted() {
        // console.log("working");
        const cytoscape = require('cytoscape');
        const dagre = require('cytoscape-dagre');
        const container = this.el;
        const storyId = container.dataset.storyId;

        if (!storyId) return;  // Add validation      

        cytoscape.use(dagre);

        // Initialize cytoscape
        const cy = cytoscape({
            container: container,
            style: [
                {
                    selector: 'node',
                    style: {
                        'label': 'data(label)',
                        'background-color': '#666',
                        'width': 80,
                        'height': 80,
                        'text-wrap': 'wrap'
                    }
                },
                {
                    selector: 'node[root = "true"]',
                    style: {
                        'background-color': '#4CAF50'
                    }
                },
                {
                    selector: 'edge',
                    style: {
                        'label': 'data(label)',
                        'curve-style': 'bezier',
                        'target-arrow-shape': 'triangle'
                    }
                }
            ],
            layout: {
                name: 'breadthfirst', // or 'breadthfirst' for more tree-like layout
                rankDir: 'TB',
                padding: 50
            },
            minZoom: 0.2,
            maxZoom: 2.0,
        });

        // Load graph data
        this.pushEventTo(this.el, "load_graph_data", { story_id: storyId }, (reply) => {
            cy.add(reply.elements);

            cy.nodes().forEach(node => {
                console.log("Node:", node.id(), "Root:", node.data('root'));
            });
            
            cy.layout({ name: 'dagre' }).run();
            cy.fit();
        });
    }
};

export default StoryVisualizer;