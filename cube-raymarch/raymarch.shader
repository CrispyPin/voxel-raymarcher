shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler3D voxels;
const float grid_size = 32.;

float mincomp(in vec3 p ) { return min(p.x,min(p.y,p.z));}
float maxcomp(in vec3 p ) { return max(p.x,max(p.y,p.z));}

void vertex() {

}

vec4 get_voxel(vec3 pos) {
	if (pos != clamp(pos, vec3(0), vec3(32))) return vec4(0);
	return texture(voxels, floor(pos) / grid_size, 0);
}

vec4 plane_march(vec3 cam_pos, vec3 surf_pos) {
	vec3 ro = cam_pos;
	vec3 ray_dir = normalize(surf_pos - ro);
	float ray_len = 0.;
	int steps = 0;
	vec3 prev_p = ro;
	while (ray_len <= 100.0 && steps < 1000) {
		steps++;
		vec3 p = ro + ray_len * ray_dir;
		vec4 col = get_voxel(p);
		if (col.a > 0.) {
			vec3 norm = normalize(floor(prev_p) - floor(p));
			float sun_light = clamp(dot(norm, normalize(vec3(1., 4., 2.))), 0, 1);
			sun_light = max(sun_light, 0.05);
			col.rgb *= vec3(sun_light);
			return col;
			//return texture(voxels, surf_pos, 0);
		}
		
		vec3 deltas = (step(0, ray_dir) - fract(p)) / ray_dir;
		//deltas = fract(p) / ray_dir;
		ray_len += max(mincomp(deltas), 0.001);
		prev_p = p;
	}
	return vec4(0.0);
}

void fragment() {
	vec3 surface_pos = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 cam_pos = CAMERA_MATRIX[3].xyz;
	vec4 col = plane_march(cam_pos, surface_pos);
	ALBEDO = col.rgb;
	if (col.a < 0.1) {
		discard;
	}
	
}
