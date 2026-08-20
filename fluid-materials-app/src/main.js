import * as THREE from 'https://cdn.jsdelivr.net/npm/three@0.161.0/build/three.module.js';

const shader_root = './src/shaders/';
const material_names = ['helium', 'water', 'gas'];

async function load_text(url) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Не удалось загрузить ${url}`);
    return response.text();
}

async function create_material(name) {
    const [vertex_shader, common_shader, fragment_shader] = await Promise.all([
        load_text(`${shader_root}vertex.glsl`),
        load_text(`${shader_root}common.glsl`),
        load_text(`${shader_root}${name}.glsl`)
    ]);
    const material = new THREE.ShaderMaterial({
        vertexShader: vertex_shader,
        fragmentShader: `${common_shader}\n${fragment_shader}`,
        uniforms: {
            u_resolution: { value: new THREE.Vector2() },
            u_mouse: { value: new THREE.Vector2() },
            u_time: { value: 0 },
            u_press_duration: { value: 0 },
            u_shockwave: { value: 1 }
        }
    });
    return material;
}

async function init() {
    const canvas = document.getElementById('fluidCanvas');
    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    const scene = new THREE.Scene();
    const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
    const materials = {};
    for (const name of material_names) materials[name] = await create_material(name);
    const mesh = new THREE.Mesh(new THREE.PlaneGeometry(2, 2), materials.helium);
    scene.add(mesh);

    let pressed = false;
    let press_time = 0;
    let shockwave = 1;
    const target_mouse = new THREE.Vector2();
    const current_mouse = new THREE.Vector2();
    const pixel_ratio = () => renderer.getPixelRatio();
    const update_mouse = (x, y) => target_mouse.set(x * pixel_ratio(), (innerHeight - y) * pixel_ratio());
    const resize = () => {
        renderer.setSize(innerWidth, innerHeight);
        Object.values(materials).forEach((material) => material.uniforms.u_resolution.value.set(innerWidth * pixel_ratio(), innerHeight * pixel_ratio()));
    };
    const press_start = (x, y) => { pressed = true; shockwave = 0; update_mouse(x, y); };
    addEventListener('resize', resize);
    addEventListener('mousemove', (event) => update_mouse(event.clientX, event.clientY));
    addEventListener('mousedown', (event) => press_start(event.clientX, event.clientY));
    addEventListener('mouseup', () => { pressed = false; });
    addEventListener('touchstart', (event) => { const touch = event.touches[0]; if (touch) press_start(touch.clientX, touch.clientY); }, { passive: true });
    addEventListener('touchmove', (event) => { const touch = event.touches[0]; if (touch) update_mouse(touch.clientX, touch.clientY); }, { passive: true });
    addEventListener('touchend', () => { pressed = false; });
    document.querySelectorAll('[data-material]').forEach((button) => button.addEventListener('click', () => {
        mesh.material = materials[button.dataset.material];
        document.querySelectorAll('[data-material]').forEach((item) => item.setAttribute('aria-pressed', String(item === button)));
    }));

    resize();
    const clock = new THREE.Clock();
    const animate = () => {
        requestAnimationFrame(animate);
        const delta = clock.getDelta();
        current_mouse.lerp(target_mouse, 0.06);
        press_time = THREE.MathUtils.clamp(press_time + (pressed ? delta * 1.1 : -delta * 0.9), 0, 2);
        shockwave = Math.min(shockwave + delta * 1.5, 1);
        Object.values(materials).forEach((material) => {
            material.uniforms.u_time.value = clock.getElapsedTime();
            material.uniforms.u_mouse.value.copy(current_mouse);
            material.uniforms.u_press_duration.value = press_time;
            material.uniforms.u_shockwave.value = shockwave;
        });
        renderer.render(scene, camera);
    };
    animate();
}

init().catch((error) => { console.error(error); document.body.textContent = 'Не удалось запустить WebGL-сцену.'; });
