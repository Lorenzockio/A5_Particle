struct VertexInput {
  @location(0) pos: vec2f,
  @builtin(instance_index) instance: u32,
};

struct VertexOutput {
  @builtin(position) pos: vec4f,
  @location(0) uv: vec2f,
  @location(1) shr: f32,
  @location(2) pT: f32,
};

struct Particle {
  pos: vec2f,
  vel: vec2f,   
  pType: f32,   
  pad: f32      
};


@group(0) @binding(0) var<uniform> frame: f32;
@group(0) @binding(1) var<uniform> res:   vec2f;
@group(0) @binding(2) var<storage> state: array<Particle>;

@vertex 
fn vs( input: VertexInput ) -> VertexOutput {
  var out: VertexOutput;
  let p = state[ input.instance ];

  var shrink = 1.;
  if (p.pos.x >= -.15) {
    shrink = 0.85 - p.pos.x;
  }

  out.shr = shrink;
  var size = input.pos * .15 * shrink;
  if (p.pType > 0) {
    size = input.pos * .0075;
  }

  let aspect = res.y / res.x;
  out.pos = vec4f( p.pos.x - size.x * aspect, p.pos.y + size.y, 0., 1.);
  out.uv = input.pos;
  out.pT = p.pType;
  return out;
}

@fragment 
fn fs( input: VertexOutput ) -> @location(0) vec4f {

  let dist = length( input.uv );
  if( dist > 1.0 ) { discard; }
  var color: vec3f;
  color = vec3f(1., 0.75, 0.8);
  if( dist < (input.shr - 0.4)) {
    color = vec3f(1., 1., 1.);
  }
  if (input.pT > 0) {
    color = vec3f(1., 0.75, 0.8);
  }
  if(input.shr <= 0) {
    color = vec3f(0., 0., 0.);
  }
  return vec4f(color, 1.);
}
