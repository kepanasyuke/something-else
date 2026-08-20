float cloud_height(vec2 point, float press, float shift) {
    float time = (u_time + shift) * 0.15;
    float large = snoise(vec3(point * 0.6, time * 0.25)) * 0.8;
    float medium = snoise(vec3(point * 1.8 - vec2(time * 0.2), time * 0.5)) * 0.25;
    float small = snoise(vec3(point * 4.0, time)) * 0.06;
    float result = large + medium + small + press * 0.02;
    return result;
}

void main() {
    float press;
    vec2 point = deformed_position(press);
    vec3 normal = compute_normal(point, press, 0.0, 0.0035, 0.20);
    vec3 light_direction = normalize(vec3(0.2, 0.9, 0.5));
    float diffuse = max(dot(normal, light_direction), 0.0);
    float specular = pow(max(dot(reflect(-light_direction, normal), vec3(0.0, 0.0, 1.0)), 0.0), 12.0);
    float density = clamp(0.5 + cloud_height(point, press, 0.0), 0.0, 1.0);
    vec3 color = mix(vec3(0.18, 0.22, 0.25), vec3(0.86, 0.9, 0.9), density);
    color += vec3(0.35, 0.55, 0.6) * diffuse * 0.4;
    color += vec3(1.0) * specular * 0.3;
    color *= vignette(gl_FragCoord.xy);
    gl_FragColor = vec4(pow(max(color, 0.0), vec3(1.18)), 1.0);
}
