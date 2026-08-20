import { useMemo } from 'react';
import * as THREE from 'three';

export function VisualHintArrow({ face, clockwise }) {
  const arrow = useMemo(() => {
    const radius = 1.6;
    let position = [0, 0, 0];
    let rotation = [0, 0, 0];
    let endAngle = clockwise ? -Math.PI / 2 : Math.PI / 2;
    switch (face) {
      case 'U': position = [0, 1.55, 0]; rotation = [Math.PI / 2, 0, 0]; break;
      case 'D': position = [0, -1.55, 0]; rotation = [-Math.PI / 2, 0, 0]; endAngle = clockwise ? Math.PI / 2 : -Math.PI / 2; break;
      case 'R': position = [1.55, 0, 0]; rotation = [0, Math.PI / 2, 0]; break;
      case 'L': position = [-1.55, 0, 0]; rotation = [0, -Math.PI / 2, 0]; endAngle = clockwise ? Math.PI / 2 : -Math.PI / 2; break;
      case 'F': position = [0, 0, 1.55]; break;
      case 'B': position = [0, 0, -1.55]; rotation = [0, Math.PI, 0]; endAngle = clockwise ? Math.PI / 2 : -Math.PI / 2; break;
      default: break;
    }
    const points = new THREE.EllipseCurve(0, 0, radius, radius, 0, endAngle, clockwise, 0).getPoints(30);
    return { geometry: new THREE.BufferGeometry().setFromPoints(points), position, rotation };
  }, [face, clockwise]);

  const tipAngle = clockwise ? -Math.PI / 2 : Math.PI / 2;
  return (
    <group position={arrow.position} rotation={arrow.rotation}>
      <line geometry={arrow.geometry}><lineBasicMaterial color="#00ffff" transparent opacity={0.8} /></line>
      <mesh position={[1.6 * Math.cos(tipAngle), 1.6 * Math.sin(tipAngle), 0]} rotation={[0, 0, clockwise ? -Math.PI / 4 : Math.PI / 4]}>
        <coneGeometry args={[0.15, 0.3, 4]} />
        <meshBasicMaterial color="#00ffff" transparent opacity={0.9} />
      </mesh>
    </group>
  );
}