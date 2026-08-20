uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_press_duration;
uniform float u_shockwave;
varying vec2 vUv;

vec4 permute(vec4 x) {
    return mod(((x * 34.0) + 1.0) * x, 289.0);
}

vec4 taylorInvSqrt(vec4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
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

    vec4 p = permute(permute(permute(
        cell.z + vec4(0.0, i1.z, i2.z, 1.0)
    ) + cell.y + vec4(0.0, i1.y, i2.y, 1.0)) + cell.x + vec4(0.0, i1.x, i2.x, 1.0));
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
    vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m *= m;
    return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

float hash(vec2 point) {
    return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453123);
}

float metalHeight(vec2 point, float press, float shift, float vortexAngle) {
    float time = (u_time + shift) * 0.35;
    if (press > 0.01) {
        float c = cos(vortexAngle);
        float s = sin(vortexAngle);
        point = vec2(point.x * c - point.y * s, point.x * s + point.y * c);
    }

    float base = snoise(vec3(point * 1.5, time * 0.6)) * 0.65;
    float detail = snoise(vec3(point * 3.5 - vec2(time * 0.4), time * 0.9)) * 0.22;
    float grain = snoise(vec3(point * (14.0 + press * 20.0), time * (4.0 + press * 6.0))) * (0.07 * press);
    return base + detail + grain;
}

vec3 renderMetal(vec3 normal, float silverAmount, vec3 lightDirection, vec3 viewDirection) {
    vec3 reflection = reflect(-lightDirection, normal);
    float broadHighlight = pow(max(dot(reflection, viewDirection), 0.0), 18.0);
    float sharpHighlight = pow(max(dot(reflection, viewDirection), 0.0), 300.0);
    float environment = dot(normal, vec3(0.0, 1.0, 0.0)) * 0.5 + 0.5;
    float fresnel = pow(1.0 - max(dot(normal, viewDirection), 0.0), 3.5);

    vec3 mercury = vec3(0.03, 0.04, 0.06) + vec3(0.18, 0.20, 0.24) * environment;
    mercury += vec3(0.3) * broadHighlight;
    mercury = mix(mercury, vec3(0.38, 0.40, 0.45), fresnel * 0.45);

    vec3 silver = vec3(0.70, 0.72, 0.80) + vec3(0.30, 0.32, 0.38) * environment;
    silver += vec3(1.6) * sharpHighlight + vec3(0.4) * broadHighlight;
    silver = mix(silver, vec3(1.0), fresnel * 0.7);
    return mix(mercury, silver, silverAmount);
}

void main() {
    vec2 pixel = gl_FragCoord.xy;
    vec2 centered = (pixel - 0.5 * u_resolution.xy) / u_resolution.y;
    float distanceToMouse = distance(pixel, u_mouse);
    float radius = 380.0 * min(u_resolution.x / 1280.0, 1.0);
    float influence = smoothstep(radius, 0.0, distanceToMouse);
    float pressEffect = clamp(u_press_duration * influence, 0.0, 1.0);
    float vortexAngle = pressEffect * u_press_duration * 1.8 * (1.0 - distanceToMouse / max(radius, 1.0));

    float waveRadius = u_shockwave * 450.0;
    float waveForce = smoothstep(35.0, 0.0, abs(distanceToMouse - waveRadius))
        * (1.0 - smoothstep(450.0, 0.0, waveRadius)) * 0.18;
    vec2 direction = normalize(pixel - u_mouse);
    if (distanceToMouse < 0.001) direction = vec2(0.0);
    vec2 deformed = centered - direction * (pressEffect * 0.12 + waveForce) * (u_resolution.x / u_resolution.y);

    float edge = 0.0035;
    float dispersion = 0.022 * pressEffect;
    float redHeight = metalHeight(deformed, pressEffect, 0.0, vortexAngle);
    float greenHeight = metalHeight(deformed, pressEffect, dispersion, vortexAngle);
    vec3 redNormal = normalize(vec3(
        (redHeight - metalHeight(deformed + vec2(edge, 0.0), pressEffect, 0.0, vortexAngle)) / edge,
        (redHeight - metalHeight(deformed + vec2(0.0, edge), pressEffect, 0.0, vortexAngle)) / edge,
        0.32
    ));
    vec3 greenNormal = normalize(vec3(
        (greenHeight - metalHeight(deformed + vec2(edge, 0.0), pressEffect, dispersion, vortexAngle)) / edge,
        (greenHeight - metalHeight(deformed + vec2(0.0, edge), pressEffect, dispersion, vortexAngle)) / edge,
        0.32
    ));

    float surfaceGrain = (hash(pixel) - 0.5) * 0.025 * (1.0 - pressEffect * 0.5);
    redNormal.xy += surfaceGrain;
    greenNormal.xy += surfaceGrain;
    vec3 lightDirection = normalize(vec3(0.35, 0.75, 1.0));
    vec3 viewDirection = vec3(0.0, 0.0, 1.0);

    vec3 color;
    color.r = renderMetal(redNormal, pressEffect, lightDirection, viewDirection).r;
    color.g = renderMetal(greenNormal, pressEffect, lightDirection, viewDirection).g;
    color.b = renderMetal(greenNormal, pressEffect, lightDirection, viewDirection).b;
    color -= vec3(max(0.0, 0.4 - redHeight)) * 0.28;

    vec2 vignetteUv = pixel / u_resolution.xy;
    float vignette = vignetteUv.x * vignetteUv.y * (1.0 - vignetteUv.x) * (1.0 - vignetteUv.y);
    color *= mix(0.45, 1.0, clamp(pow(16.0 * vignette, 0.35), 0.0, 1.0));
    gl_FragColor = vec4(pow(max(color, 0.0), vec3(1.22)), 1.0);
}
