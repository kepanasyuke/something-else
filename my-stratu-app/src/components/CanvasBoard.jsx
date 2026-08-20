import { motion } from 'framer-motion';

function CanvasBoard({ filteredImages }) {
    return (
        <section className="canvas-board">
            <div className="board-header"><span>ACTIVE_NODES: {filteredImages.length}</span><span>DRAG_MODE: FREE_FLOW</span></div>
            <div className="card-field">
                {filteredImages.map((image, index) => (
                    <motion.article
                        className="image-card"
                        drag
                        dragMomentum
                        whileDrag={{ scale: 1.04, zIndex: 5 }}
                        initial={{ opacity: 0, y: 18 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.07 }}
                        key={image.id}
                    >
                        <div className="card-label">{image.id} <span>// {image.category}</span></div>
                        <div className="image-wrap"><img src={image.url} alt={image.title} /></div>
                        <h2>{image.title}</h2>
                        <footer><div className="palette">{image.hex_palette.map((color) => <i key={color} style={{ backgroundColor: color }} />)}</div><div className="metrics">G:{image.metrics.geo} / T:{image.metrics.tex}</div></footer>
                    </motion.article>
                ))}
            </div>
        </section>
    );
}

export default CanvasBoard;
