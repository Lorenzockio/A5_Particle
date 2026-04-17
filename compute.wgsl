struct Particle {
  pos: vec2f,
  vel: vec2f
};

@group(0) @binding(0) var<uniform> res:   vec2f;
@group(0) @binding(1) var<storage, read_write> state: array<Particle>;
@group(0) @binding(2) var<uniform> mouse:   vec3f;
@group(0) @binding(3) var<uniform> prev_mouse: vec3f;


fn cellindex( cell:vec3u ) -> u32 {
  let size = 8u;
  return cell.x + (cell.y * size) + (cell.z * size * size);
}

@compute
@workgroup_size(8,8)
fn cs(@builtin(global_invocation_id) cell:vec3u)  {
  let i = cellindex( cell );
  let p = state[ i ];

  var vel = p.vel;
  vel.y -= 0.01;

  var next = p.pos + (2. / res) * vel;

  if( next.y <= -1. ) {
    next.y = -1.;
    vel.y *= -1.;
  }
  if( next.y >= 1. ) {
    next.y = 1.;
    vel.y *= -1.;
  }
  if(mouse.z > 0.5) { 
    next.x = -1.; 
  }
  let released = prev_mouse.z > 0.5 && mouse.z <= 0.5;
  if (released) {
    vel.y = next.y * 7.;
  }
  if(next.x == 2.){
    next.x = -1.; 
  }

  state[i].pos = next;
  state[i].vel = vel;
}