import { useMemo } from 'react';

function getNextSolutionStep(currentMatrix) {
  const frontCenter = currentMatrix.find((cubie) => cubie.currentPos.x === 0 && cubie.currentPos.y === 0 && cubie.currentPos.z === 1);
  const upFrontEdge = currentMatrix.find((cubie) => cubie.currentPos.x === 0 && cubie.currentPos.y === 1 && cubie.currentPos.z === 1);
  if (upFrontEdge && frontCenter && upFrontEdge.faces.front !== frontCenter.faces.front) {
    return { face: 'U', clockwise: true, text: 'Разверни верхнюю грань, чтобы совместить ребро' };
  }
  return { face: 'R', clockwise: true, text: 'Выполни базовое движение правой грани (R)' };
}

export function BeginnerAssistantHUD({ currentMatrix }) {
  const currentStep = useMemo(() => getNextSolutionStep(currentMatrix), [currentMatrix]);
  return (
    <div className="assistant-hud">
      <div className="eyebrow">Ассистент сборки</div>
      <div className="assistant-text">{currentStep.text}</div>
      <div className="next-move">Следующий ход: <span>{currentStep.face}{currentStep.clockwise ? '' : "'"}</span></div>
    </div>
  );
}