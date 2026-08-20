export const WCA_COLORS = {
  U: '#FFFFFF',
  D: '#FFFF00',
  F: '#00FF00',
  B: '#0000FF',
  L: '#FF0000',
  R: '#FFA500'
};

export function generateInitialCubeMatrix() {
  const matrix = [];
  let id = 0;
  for (let x = -1; x <= 1; x += 1) {
    for (let y = -1; y <= 1; y += 1) {
      for (let z = -1; z <= 1; z += 1) {
        matrix.push({
          id: id++,
          initialPos: { x, y, z },
          currentPos: { x, y, z },
          faces: {
            up: y === 1 ? WCA_COLORS.U : null,
            down: y === -1 ? WCA_COLORS.D : null,
            front: z === 1 ? WCA_COLORS.F : null,
            back: z === -1 ? WCA_COLORS.B : null,
            left: x === -1 ? WCA_COLORS.L : null,
            right: x === 1 ? WCA_COLORS.R : null
          },
          meta: { isHighlighted: false, isCoreMechanism: x === 0 && y === 0 && z === 0 }
        });
      }
    }
  }
  return matrix;
}

export function rotateFace(currentMatrix, face, clockwise = true) {
  const angle = clockwise ? -Math.PI / 2 : Math.PI / 2;
  const cos = Math.round(Math.cos(angle));
  const sin = Math.round(Math.sin(angle));

  return currentMatrix.map((cubie) => {
    const { x, y, z } = cubie.currentPos;
    const isTargetLayer = face === 'U' ? y === 1 : face === 'D' ? y === -1 : face === 'F' ? z === 1 : face === 'B' ? z === -1 : face === 'L' ? x === -1 : face === 'R' ? x === 1 : false;
    if (!isTargetLayer) return cubie;

    let newX = x;
    let newY = y;
    let newZ = z;
    const newFaces = { ...cubie.faces };

    if (face === 'F' || face === 'B') {
      newX = x * cos - y * sin;
      newY = x * sin + y * cos;
      if (clockwise) Object.assign(newFaces, { up: cubie.faces.left, right: cubie.faces.up, down: cubie.faces.right, left: cubie.faces.down });
      else Object.assign(newFaces, { up: cubie.faces.right, left: cubie.faces.up, down: cubie.faces.left, right: cubie.faces.down });
    } else if (face === 'U' || face === 'D') {
      newX = x * cos + z * sin;
      newZ = -x * sin + z * cos;
      if (clockwise) Object.assign(newFaces, { front: cubie.faces.right, left: cubie.faces.front, back: cubie.faces.left, right: cubie.faces.back });
      else Object.assign(newFaces, { front: cubie.faces.left, right: cubie.faces.front, back: cubie.faces.right, left: cubie.faces.back });
    } else {
      newY = y * cos - z * sin;
      newZ = y * sin + z * cos;
      if (clockwise) Object.assign(newFaces, { up: cubie.faces.front, back: cubie.faces.up, down: cubie.faces.back, front: cubie.faces.down });
      else Object.assign(newFaces, { up: cubie.faces.back, front: cubie.faces.up, down: cubie.faces.front, back: cubie.faces.down });
    }

    return { ...cubie, currentPos: { x: newX, y: newY, z: newZ }, faces: newFaces };
  });
}