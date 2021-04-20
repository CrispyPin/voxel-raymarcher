shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler3D voxels;
const vec3 sun_pos = vec3(3, 8, 5);
const float grid_size = 32.;

float mincomp(in vec3 p ) { return min(p.x,min(p.y,p.z));}
float maxcomp(in vec3 p ) { return max(p.x,max(p.y,p.z));}
float absmax(float a, float b) {
	if (abs(a) > abs(b)) return a;
	return b;
}
float absmaxcomp(in vec3 p ) {return absmax(p.x, absmax(p.y, p.z));}

vec4 get_voxel(vec3 pos) {
	if (pos != clamp(pos, vec3(0), vec3(32))) return vec4(0);
	return texture(voxels, pos / grid_size);
}	

vec3 get_normal(vec3 pos) {
	pos = fract(pos);
	pos = normalize(pos - 0.5); // centered coords
	vec3 norm;
	if (pos.x == absmaxcomp(pos)) {
		norm = vec3(1,0,0) * sign(pos.x);
	}
	else if (pos.y == absmaxcomp(pos)) {
		norm = vec3(0,1,0) * sign(pos.y);
	}
	else {
		norm = vec3(0,0,1) * sign(pos.z);
	}
	return normalize(norm);
}

vec4 light_point(vec3 pos) {
	vec4 col = get_voxel(pos - fract(pos)+0.5);
	vec3 norm = get_normal(pos);
	float sun_light = clamp(dot(norm, normalize(sun_pos)), 0, 1);
	sun_light = max(sun_light, 0.0);
	sun_light = sun_light*0.4+0.1;
	col.rgb *= sun_light;
	//col.rgb = norm*0.5+0.5;
	//col = vec4(vec3(float(steps)/200.), 1);
	return col;
}

vec4 plane_march(vec3 cam_pos, vec3 surf_pos) {
	vec3 ro = cam_pos;
	vec3 ray_dir = normalize(surf_pos - ro);
	float ray_len = 0.0;
	int steps = 0;
	while (ray_len <= 100.0 && steps < 200) {
		steps++;
		vec3 p = ro + ray_len * ray_dir;
		float solid = get_voxel(p - fract(p)+0.5).a;
		if (solid > 0.) {
			return light_point(p);
		}
		vec3 deltas = (step(0, ray_dir) - fract(p)) / ray_dir;
		ray_len += max(mincomp(deltas), 0.001);
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
