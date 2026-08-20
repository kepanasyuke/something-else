import { useEffect, useMemo, useRef, useState } from 'react';
import { calculateWCAAverage, formatTime } from '../utils/wcaStatistics';

export function StackmatTimer({ onTimerStop, solveHistory }) {
  const [timerState, setTimerState] = useState('idle');
  const [time, setTime] = useState(0);
  const intervalRef = useRef(null);
  const startTimeRef = useRef(0);
  const pressTimeoutRef = useRef(null);

  const handleHandPlace = () => {
    if (timerState === 'running') {
      clearInterval(intervalRef.current);
      setTimerState('idle');
      onTimerStop(time);
    } else if (timerState === 'idle') {
      setTimerState('pressing');
      pressTimeoutRef.current = setTimeout(() => setTimerState('ready'), 500);
    }
  };

  const handleHandRelease = () => {
    if (timerState === 'pressing') {
      clearTimeout(pressTimeoutRef.current);
      setTimerState('idle');
    } else if (timerState === 'ready') {
      setTimerState('running');
      startTimeRef.current = performance.now();
      intervalRef.current = setInterval(() => setTime(performance.now() - startTimeRef.current), 10);
    }
  };

  useEffect(() => {
    const handleKeyDown = (event) => {
      if (event.key === ' ') {
        event.preventDefault();
        handleHandPlace();
      }
    };
    const handleKeyUp = (event) => {
      if (event.key === ' ') {
        event.preventDefault();
        handleHandRelease();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
      clearInterval(intervalRef.current);
      clearTimeout(pressTimeoutRef.current);
    };
  });

  const ao5 = useMemo(() => calculateWCAAverage(solveHistory, 5), [solveHistory]);
  const ao12 = useMemo(() => calculateWCAAverage(solveHistory, 12), [solveHistory]);
  const timerColor = { pressing: '#ff3b30', ready: '#34c759', running: '#ffffff', idle: '#ffa500' }[timerState];

  return (
    <div className="timer-panel">
      <h1 onMouseDown={handleHandPlace} onMouseUp={handleHandRelease} onTouchStart={handleHandPlace} onTouchEnd={handleHandRelease} style={{ color: timerColor }}>
        {formatTime(time)}
      </h1>
      <div className="stats-row">
        <div>Последний: <strong>{formatTime(solveHistory[solveHistory.length - 1] || 0)}</strong></div>
        <div>Ao5: <strong>{ao5}</strong></div>
        <div>Ao12: <strong>{ao12}</strong></div>
      </div>
    </div>
  );
}