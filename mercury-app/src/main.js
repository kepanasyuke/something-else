import * as THREE from 'https://cdn.jsdelivr.net/npm/three@0.161.0/build/three.module.js';

async function loadShader(url) {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`Не удалось загрузить шейдер: ${url}`);
    }
    return response.text();
}

async function init() {
    const [vertexShader, fragmentShader] = await Promise.all([
        loadShader('./src/shaders/vertex.glsl'),
        loadShader('./src/shaders/fragment.glsl')
    ]);

    const canvas = document.getElementById('fluidCanvas');
    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    const scene = new THREE.Scene();
    const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
    const uniforms = {
        u_resolution: { value: new THREE.Vector2() },
        u_mouse: { value: new THREE.Vector2() },
        u_time: { value: 0 },
        u_press_duration: { value: 0 },
        u_shockwave: { value: 1 }
    };

    const material = new THREE.ShaderMaterial({
        vertexShader,
        fragmentShader,
        uniforms
    });
    scene.add(new THREE.Mesh(new THREE.PlaneGeometry(2, 2), material));

    let isPressed = false;
    let pressTime = 0;
    let shockwaveProgress = 1;
    const targetMouse = new THREE.Vector2();
    const currentMouse = new THREE.Vector2();

    function resize() {
        renderer.setSize(window.innerWidth, window.innerHeight);
        uniforms.u_resolution.value.set(
            window.innerWidth * renderer.getPixelRatio(),
            window.innerHeight * renderer.getPixelRatio()
        );
    }

    function updateMousePosition(x, y) {
        targetMouse.set(x * renderer.getPixelRatio(), (window.innerHeight - y) * renderer.getPixelRatio());
    }

    function startPress(x, y) {
        isPressed = true;
        shockwaveProgress = 0;
        updateMousePosition(x, y);
    }

    window.addEventListener('resize', resize);
    window.addEventListener('mousemove', (event) => updateMousePosition(event.clientX, event.clientY));
    window.addEventListener('mousedown', (event) => startPress(event.clientX, event.clientY));
    window.addEventListener('mouseup', () => { isPressed = false; });
    window.addEventListener('mouseleave', () => { isPressed = false; });
    window.addEventListener('touchstart', (event) => {
        const touch = event.touches[0];
        if (touch) startPress(touch.clientX, touch.clientY);
    }, { passive: true });
    window.addEventListener('touchmove', (event) => {
        const touch = event.touches[0];
        if (touch) updateMousePosition(touch.clientX, touch.clientY);
    }, { passive: true });
    window.addEventListener('touchend', () => { isPressed = false; });

    resize();
    const clock = new THREE.Clock();

    function animate() {
        requestAnimationFrame(animate);
        const delta = clock.getDelta();
        uniforms.u_time.value = clock.getElapsedTime();
        currentMouse.lerp(targetMouse, 0.06);
        uniforms.u_mouse.value.copy(currentMouse);

        pressTime += (isPressed ? delta * 1.1 : -delta * 0.9);
        pressTime = THREE.MathUtils.clamp(pressTime, 0, 2);
        uniforms.u_press_duration.value = pressTime;

        shockwaveProgress = Math.min(shockwaveProgress + delta * 1.5, 1);
        uniforms.u_shockwave.value = shockwaveProgress;
        renderer.render(scene, camera);
    }

    animate();
}

init().catch((error) => {
    console.error(error);
    document.body.textContent = 'Не удалось запустить WebGL-сцену. Откройте консоль браузера для подробностей.';
});
