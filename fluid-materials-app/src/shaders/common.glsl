uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_press_duration;
uniform float u_shockwave;
varying vec2 v_uv;

vec4 permute(vec4 value) {
    vec4 result = mod(((value * 34.0) + 1.0) * value, 289.0);
    return result;
}

vec4 taylor_inv_sqrt(vec4 value) {
    vec4 result = 1.79284291400159 - 0.85373472095314 * value;
    return result;
}

float snoise(vec3 value) {
    const vec2 c = vec2(1.0 / 6.0, 1.0 / 3.0);
    const vec4 d = vec4(0.0, 0.5, 1.0, 2.0);
    vec3 cell = floor(value + dot(value, c.yyy));
    vec3 x0 = value - cell + dot(cell, c.xxx);
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);
    vec3 x1 = x0 - i1 + c.xxx;
    vec3 x2 = x0 - i2 + 2.0 * c.xxx;
    vec3 x3 = x0 - d.yyy;
    cell = mod(cell, 289.0);
    vec4 p = permute(permute(permute(cell.z + vec4(0.0, i1.z, i2.z, 1.0)) + cell.y + vec4(0.0, i1.y, i2.y, 1.0)) + cell.x + vec4(0.0, i1.x, i2.x, 1.0));
    float n = 1.0 / 7.0;
    vec3 ns = n * d.wyz - d.xzx;
    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);
    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);
    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);
    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);
    vec4 norm = taylor_inv_sqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x; p1 *= norm.y; p2 *= norm.z; p3 *= norm.w;
    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m *= m;
    float result = 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
    return result;
}

vec2 deformed_position(out float press) {
    vec2 pixel = gl_FragCoord.xy;
    vec2 centered = (pixel - 0.5 * u_resolution.xy) / u_resolution.y;
    float distance_to_mouse = distance(pixel, u_mouse);
    float radius = 380.0 * min(u_resolution.x / 1280.0, 1.0);
    float influence = smoothstep(radius, 0.0, distance_to_mouse);
    press = clamp(u_press_duration * influence, 0.0, 1.0);
    float wave_radius = u_shockwave * 450.0;
    float wave_force = smoothstep(35.0, 0.0, abs(distance_to_mouse - wave_radius)) * (1.0 - smoothstep(450.0, 0.0, wave_radius)) * 0.16;
    vec2 direction = normalize(pixel - u_mouse);
    if (distance_to_mouse < 0.001) direction = vec2(0.0);
    float displacement = (press * 0.12 + wave_force) * (u_resolution.x / u_resolution.y);
    vec2 result = centered - direction * displacement;
    return result;
}

vec3 compute_normal(vec2 point, float press, float shift, float epsilon, float depth) {
    float height = snoise(vec3(point * 1.5, (u_time + shift) * 0.3)) * 0.65;
    float height_x = snoise(vec3((point + vec2(epsilon, 0.0)) * 1.5, (u_time + shift) * 0.3)) * 0.65;
    float height_y = snoise(vec3((point + vec2(0.0, epsilon)) * 1.5, (u_time + shift) * 0.3)) * 0.65;
    vec3 result = normalize(vec3((height_x - height) / epsilon, (height_y - height) / epsilon, depth));
    return result;
}

float vignette(vec2 pixel) {
    vec2 uv = pixel / u_resolution;
    float value = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    float result = mix(0.32, 1.0, clamp(pow(16.0 * value, 0.35), 0.0, 1.0));
    return result;
}
