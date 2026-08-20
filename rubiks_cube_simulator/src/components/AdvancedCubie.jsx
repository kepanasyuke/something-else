import { useMemo } from 'react';
import * as THREE from 'three';
import { generateHoneycombNormalMap } from '../utils/honeycombNormalMap';

export function AdvancedCubie({ position, faces, isXRayMode }) {
  const normalTexture = useMemo(() => {
    const texture = new THREE.CanvasTexture(generateHoneycombNormalMap());
    texture.wrapS = THREE.RepeatWrapping;
    texture.wrapT = THREE.RepeatWrapping;
    texture.repeat.set(2, 2);
    return texture;
  }, []);

  const materialConfig = useMemo(() => ({
    roughness: 0.5,
    metalness: 0.1,
    clearcoat: 0.2,
    clearcoatRoughness: 0.4,
    normalMap: normalTexture,
    transparent: isXRayMode,
    opacity: isXRayMode ? 0.3 : 1,
    depthWrite: !isXRayMode
  }), [isXRayMode, normalTexture]);

  const materials = useMemo(() => ['right', 'left', 'up', 'down', 'front', 'back'].map((faceName) => {
    const faceColor = faces[faceName];
    return new THREE.MeshPhysicalMaterial({
      ...materialConfig,
      color: faceColor ? new THREE.Color(faceColor) : new THREE.Color('#1a1a1a'),
      normalScale: faceColor ? new THREE.Vector2(0.1, 0.1) : new THREE.Vector2(0.5, 0.5)
    });
  }), [faces, materialConfig]);

  return (
    <mesh position={[position.x, position.y, position.z]} material={materials}>
      <boxGeometry args={[0.96, 0.96, 0.96]} />
    </mesh>
  );
}