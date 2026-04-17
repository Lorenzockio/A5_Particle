import { default as gulls } from './gulls.js'
import { default as Mouse } from './mouse.js'

const sg = await gulls.init(),
      render_shader  = await gulls.import( './render.wgsl' ),
      compute_shader = await gulls.import( './compute.wgsl' )

Mouse.init() 

const NUM_PARTICLES = 4, 
      NUM_PROPERTIES = 6, 
      state = new Float32Array( NUM_PARTICLES * NUM_PROPERTIES)

state[0] = -1;
state[1] = -1 + Math.random() * 2;
state[2] = 12;
state[3] = -7 + Math.random() * 14;
state[4] = 0;
state[5] = 0; //pad

for (let p = 1; p < NUM_PARTICLES; p++) {
  const i = p * NUM_PROPERTIES;

  state[i] = state[0];
  state[i + 1] = state[1];
  state[i + 2] = state[2];
  state[i + 3] = state[3];
  state[i + 4] = i; 
  state[i + 5] = 0; //pad
}
/*for( let i = 0; i < NUM_PARTICLES * NUM_PROPERTIES; i+= NUM_PROPERTIES) {
  state[ i ] = -1
  state[ i + 1 ] = -1 + Math.random() * 2
  state[ i + 2 ] = 12
  state[ i + 3 ] = -7 + Math.random() * 14

}*/

const state_b = sg.buffer( state ),
      frame_u = sg.uniform( 0 ),
      res_u   = sg.uniform([ sg.width, sg.height ]),
      mouse = sg.uniform( Mouse.values ),
      prev_mouse = sg.uniform( Mouse.values )

const render = await sg.render({
  shader: render_shader,
  data: [
    frame_u,
    res_u,
    state_b
  ],
  onframe() { 
    frame_u.value++ 
},
  count: NUM_PARTICLES,
  blend: true
})


const dc = Math.ceil( NUM_PARTICLES / 64 )

const compute = sg.compute({
  shader: compute_shader,
  data:[
    res_u,
    state_b,
    mouse,
    prev_mouse
  ],
  dispatchCount: [ dc, dc, 1 ],
  onframe() { 
    prev_mouse.value = mouse.value
    mouse.value = Mouse.values 
  }, 
})

sg.run( compute, render )
