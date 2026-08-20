import { useState } from 'react';
import { createRoot } from 'react-dom/client';
import RubiksCubeApp from './components/RubiksCubeApp';
import './styles.css';

function App() {
  const [mode, setMode] = useState('pro');
  return (
    <div className="app-root">
      <nav className="mode-switcher" aria-label="Режим приложения">
        <button className={mode === 'pro' ? 'active' : ''} onClick={() => setMode('pro')}>Профи</button>
        <button className={mode === 'beginner' ? 'active' : ''} onClick={() => setMode('beginner')}>Новичок</button>
      </nav>
      <RubiksCubeApp userMode={mode} />
    </div>
  );
}

createRoot(document.getElementById('root')).render(<App />);