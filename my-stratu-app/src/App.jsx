import { useEffect, useState } from 'react';
import imageDb from './data/imageDb.json';
import AuthBadge from './components/AuthBadge';
import CanvasBoard from './components/CanvasBoard';
import FilterKnobs from './components/FilterKnobs';

const defaultSliders = { geo: 50, tex: 50, clr: 50, rhm: 50 };

function App() {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [sliders, setSliders] = useState(defaultSliders);
    const [filteredImages, setFilteredImages] = useState([]);

    useEffect(() => {
        if (!isAuthenticated) return;
        const ranked = imageDb
            .map((image) => {
                const distance = Object.keys(defaultSliders).reduce(
                    (total, axis) => total + (image.metrics[axis] - sliders[axis]) ** 2,
                    0
                );
                return { ...image, distance: Math.sqrt(distance) };
            })
            .sort((first, second) => first.distance - second.distance);
        setFilteredImages(ranked);
    }, [isAuthenticated, sliders]);

    function randomizeSliders() {
        setSliders(Object.fromEntries(Object.keys(defaultSliders).map((axis) => [axis, Math.floor(Math.random() * 81) + 10])));
    }

    if (!isAuthenticated) {
        return <AuthBadge onAccessGranted={() => setIsAuthenticated(true)} />;
    }

    return (
        <main className="app-shell">
            <header className="topbar">
                <div className="brand">STRATU <span>// VISUAL ENGINE</span></div>
                <div className="status">CORE_V1.0.0_RUNNING <i /></div>
            </header>
            <div className="workspace">
                <FilterKnobs sliders={sliders} setSliders={setSliders} onEmergency={randomizeSliders} />
                <CanvasBoard filteredImages={filteredImages} />
            </div>
        </main>
    );
}

export default App;
