precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    
    // Subtle Chromatic Aberration
    // Shifting R and B slightly in opposite directions creates that "physical lens" feel.
    float offset = 0.0006;
    color.r = texture2D(tex, v_texcoord + vec2(offset, 0.0)).r;
    color.b = texture2D(tex, v_texcoord - vec2(offset, 0.0)).b;
    
    // Subtle Film Grain
    // Adds a tiny bit of "texture" so the terminal doesn't look like flat digital blocks.
    float noise = (rand(v_texcoord) - 0.5) * 0.012;
    color.rgb += noise;
    
    gl_FragColor = color;
}
