struct Particle {
  pos: vec2f,
  vel: vec2f,   
  pType: f32,   
  pad: f32      
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
  let t = p.pType;
  //bottom
  if( next.y <= -1. ) {
    next.y = -1.;
    vel.y *= -1.;
    if (t > 0) {
      vel.y = t;
      vel.x = 36;
    }
  }

  //top
  if( next.y >= 1. ) {
    next.y = 1.;
    vel.y *= -1.;
    if (t > 0) {
      vel.y = -t;
      vel.x = 36;
    }
  }

  //hold mouse
  if(mouse.z > 0.5) { 
    next.x = -1.;
    next.y = (0.5 - mouse.y) * 2; 
  }

  //release mouse
  let released = prev_mouse.z > 0.5 && mouse.z <= 0.5;
  if (released) {
    vel.y = (0.5 - mouse.y) * 14.;
    vel.x = 12.;
  }

  //right side stop
  if(next.x >= 1.5){
    vel.x = 0;
    vel.y = 0;
  }

  //left side stop - unused
  if(next.x <= -1.5){
    vel.x = 0;
    vel.y = 0;
  }

  //collision
  if (vel.x > 45) {
    vel = vec2f(0);
    next.x = 1.2;
  } else if(vel.x > 35) {
    vel.x += 1;
  }

  state[i].pos = next;
  state[i].vel = vel;
}
