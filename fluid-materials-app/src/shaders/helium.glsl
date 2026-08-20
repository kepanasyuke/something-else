float helium_height(vec2 point, float press, float shift) {
    float time = (u_time + shift) * 0.2;
    float large = snoise(vec3(point * 0.8, time * 0.4)) * 0.7;
    float medium = snoise(vec3(point * 2.0 - vec2(time * 0.3), time * 0.7)) * 0.25;
    float small = snoise(vec3(point * 5.0, time * 1.5)) * 0.08;
    float result = large + medium + small + press * 0.03;
    return result;
}

void main() {
    float press;
    vec2 point = deformed_position(press);
    vec3 normal = compute_normal(point, press, 0.0, 0.0035, 0.25);
    vec3 light_direction = normalize(vec3(0.3, 0.8, 0.6));
    float diffuse = max(dot(normal, light_direction), 0.0);
    float specular = pow(max(dot(reflect(-light_direction, normal), vec3(0.0, 0.0, 1.0)), 0.0), 20.0);
    float density = clamp(0.5 + helium_height(point, press, 0.0), 0.0, 1.0);
    vec3 color = mix(vec3(1.0, 0.56, 0.22), vec3(1.0, 0.9, 0.68), density);
    color *= 0.58 + diffuse * 0.42;
    color += vec3(1.0, 0.72, 0.35) * specular * 0.8;
    color *= vignette(gl_FragCoord.xy);
    gl_FragColor = vec4(pow(max(color, 0.0), vec3(1.2)), 1.0);
}
