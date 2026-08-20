import { useMemo, useState } from 'react';
import { Canvas } from '@react-three/fiber';
import { generateInitialCubeMatrix, rotateFace } from '../core/CubeCore';
import { AdvancedCubie } from './AdvancedCubie';
import { BeginnerAssistantHUD } from './BeginnerAssistantHUD';
import { CubeTouchHandler } from './CubeTouchHandler';
import { StackmatTimer } from './StackmatTimer';
import { VisualHintArrow } from './VisualHintArrow';

export default function RubiksCubeApp({ userMode = 'pro' }) {
  const [cubeMatrix, setCubeMatrix] = useState(() => generateInitialCubeMatrix());
  const [solveHistory, setSolveHistory] = useState([]);
  const isXRay = userMode === 'beginner';
  const currentStep = useMemo(() => {
    const frontCenter = cubeMatrix.find((cubie) => cubie.currentPos.x === 0 && cubie.currentPos.y === 0 && cubie.currentPos.z === 1);
    const upFrontEdge = cubeMatrix.find((cubie) => cubie.currentPos.x === 0 && cubie.currentPos.y === 1 && cubie.currentPos.z === 1);
    if (upFrontEdge && frontCenter && upFrontEdge.faces.front !== frontCenter.faces.front) {
      return { face: 'U', clockwise: true };
    }
    return { face: 'R', clockwise: true };
  }, [cubeMatrix]);

  const handleRotation = (face, clockwise) => {
    setCubeMatrix((previous) => rotateFace(previous, face, clockwise));
    if (navigator.vibrate) navigator.vibrate(10);
  };

  return (
    <main className="app-shell">
      <Canvas camera={{ position: [4, 3, 5], fov: 45 }}>
        <ambientLight intensity={0.6} />
        <directionalLight position={[5, 10, 7]} intensity={1.2} />
        <pointLight position={[-5, -5, 5]} intensity={0.5} />
        {cubeMatrix.map((cubie) => <AdvancedCubie key={cubie.id} position={cubie.currentPos} faces={cubie.faces} isXRayMode={isXRay} />)}
        {isXRay && <VisualHintArrow face={currentStep.face} clockwise={currentStep.clockwise} />}
        <CubeTouchHandler onRotateRequest={handleRotation} />
      </Canvas>
      {userMode === 'pro' ? (
        <div className="timer-overlay"><StackmatTimer onTimerStop={(time) => setSolveHistory((previous) => [...previous, time])} solveHistory={solveHistory} /></div>
      ) : <BeginnerAssistantHUD currentMatrix={cubeMatrix} />}
    </main>
  );
}