import { useState } from 'react';
import { useThree } from '@react-three/fiber';

export function CubeTouchHandler({ onRotateRequest }) {
  const { raycaster, mouse, camera, scene } = useThree();
  const [dragStart, setDragStart] = useState(null);

  const handlePointerDown = (event) => {
    event.stopPropagation();
    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(scene.children, true);
    if (intersects.length > 0) {
      const hit = intersects[0];
      setDragStart({
        position: hit.object.position.clone(),
        faceNormal: hit.face.normal.clone(),
        screenX: event.clientX,
        screenY: event.clientY
      });
    }
  };

  const determineRotation = (deltaX, deltaY) => {
    const { faceNormal, position } = dragStart;
    let targetFace = 'U';
    let clockwise = true;
    if (Math.abs(faceNormal.y) > 0.9) {
      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        targetFace = deltaX > 0 ? 'R' : 'L';
        clockwise = faceNormal.y > 0 ? position.z > 0 : position.z < 0;
      } else {
        targetFace = deltaY > 0 ? 'F' : 'B';
        clockwise = deltaY > 0;
      }
    } else if (Math.abs(faceNormal.z) > 0.9) {
      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        targetFace = position.y === 1 ? 'U' : 'D';
        clockwise = deltaX > 0;
      } else {
        targetFace = position.x === 1 ? 'R' : 'L';
        clockwise = deltaY < 0;
      }
    }
    onRotateRequest(targetFace, clockwise);
  };

  const handlePointerMove = (event) => {
    if (!dragStart) return;
    const deltaX = event.clientX - dragStart.screenX;
    const deltaY = event.clientY - dragStart.screenY;
    if (Math.hypot(deltaX, deltaY) > 35) {
      determineRotation(deltaX, deltaY);
      setDragStart(null);
    }
  };

  return (
    <mesh onPointerDown={handlePointerDown} onPointerMove={handlePointerMove} onPointerUp={() => setDragStart(null)} visible={false}>
      <boxGeometry args={[3.4, 3.4, 3.4]} />
      <meshBasicMaterial transparent opacity={0} />
    </mesh>
  );
}