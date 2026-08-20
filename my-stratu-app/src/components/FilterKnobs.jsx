const axisLabels = {
    geo: 'Геометрия',
    tex: 'Текстура',
    clr: 'Цвет',
    rhm: 'Ритм'
};

const axisHints = {
    geo: 'ОРГАНИКА ↔ СЕТКА',
    tex: 'СТЕРИЛЬНОСТЬ ↔ ШУМ',
    clr: 'МОНОХРОМ ↔ КИСЛОТА',
    rhm: 'СТАТИКА ↔ ХАОС'
};

function FilterKnobs({ sliders, setSliders, onEmergency }) {
    function handleChange(axis, value) {
        setSliders((previous) => ({ ...previous, [axis]: Number(value) }));
    }

    return (
        <aside className="filter-panel">
            <div>
                <div className="panel-label"><span>// КАНАЛЫ МАТРИЦЫ</span><span>ONLINE</span></div>
                <div className="knob-list">
                    {Object.keys(sliders).map((axis) => (
                        <label className="knob" key={axis}>
                            <span className="knob-title"><strong>{axisLabels[axis]}</strong><b>{sliders[axis]}%</b></span>
                            <span className="knob-hint">{axisHints[axis]}</span>
                            <input type="range" min="0" max="100" value={sliders[axis]} onChange={(event) => handleChange(axis, event.target.value)} />
                        </label>
                    ))}
                </div>
            </div>
            <button className="roulette-button" type="button" onClick={onEmergency}><span>⚠</span> НЕТ ИДЕЙ / РУЛЕТКА</button>
        </aside>
    );
}

export default FilterKnobs;
