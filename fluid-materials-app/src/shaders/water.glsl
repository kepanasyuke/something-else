float water_height(vec2 point, float press, float shift) {
    float time = (u_time + shift) * 0.35;
    float broad = snoise(vec3(point * 1.2, time * 0.5)) * 0.5;
    float medium = snoise(vec3(point * 2.8 - vec2(time * 0.3), time * 0.8)) * 0.25;
    float small = snoise(vec3(point * 5.5, time * 1.4)) * 0.08;
    float result = broad + medium + small + press * 0.05;
    return result;
}

void main() {
    float press;
    vec2 point = deformed_position(press);
    vec3 normal = compute_normal(point, press, 0.0, 0.0035, 0.30);
    vec3 light_direction = normalize(vec3(0.4, 0.7, 0.8));
    float diffuse = max(dot(normal, light_direction), 0.0);
    float specular = pow(max(dot(reflect(-light_direction, normal), vec3(0.0, 0.0, 1.0)), 0.0), 60.0);
    float fresnel = pow(1.0 - max(normal.z, 0.0), 3.0);
    float depth = clamp(0.5 + water_height(point, press, 0.0), 0.0, 1.0);
    vec3 color = mix(vec3(0.01, 0.06, 0.16), vec3(0.05, 0.42, 0.62), depth);
    color *= 0.55 + diffuse * 0.45;
    color += vec3(0.35, 0.8, 1.0) * (specular * 0.9 + fresnel * 0.18);
    color *= vignette(gl_FragCoord.xy);
    gl_FragColor = vec4(pow(max(color, 0.0), vec3(1.15)), 1.0);
}
