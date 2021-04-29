shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler3D voxels;
uniform float voxel_count;//voxels per chunk
uniform float voxel_size;//size of voxels
uniform float chunk_size;//size of chunk

const vec3 sun_pos = vec3(3, 8, 5);

float mincomp(in vec3 p ) { return min(p.x,min(p.y,p.z));}
float maxcomp(in vec3 p ) { return max(p.x,max(p.y,p.z));}
float absmax(float a, float b) {
	if (abs(a) > abs(b)) return a;
	return b;}
float absmaxcomp(in vec3 p ) {return absmax(p.x, absmax(p.y, p.z));}

vec3 world_to_voxel(vec3 wpos) {
	return wpos/voxel_size;//todo add chunk offset
}

vec4 get_voxel(vec3 wpos) {
	vec3 vsize = vec3(voxel_size);
	vec3 vpos = world_to_voxel(wpos);
	vpos = vpos - fract(vpos) + voxel_size*0.5;
	if (vpos != clamp(vpos, vec3(0), vec3(voxel_count))) return vec4(0);
	return texture(voxels, vpos / voxel_count);
}

vec3 get_normal(vec3 wpos) {
	vec3 vpos = fract(world_to_voxel(wpos));
	vpos = normalize(vpos - 0.5); // centered coords
	vec3 norm;
	if (vpos.x == absmaxcomp(vpos)) {
		norm = vec3(1,0,0) * sign(vpos.x);
	}
	else if (vpos.y == absmaxcomp(vpos)) {
		norm = vec3(0,1,0) * sign(vpos.y);
	}
	else {
		norm = vec3(0,0,1) * sign(vpos.z);
	}
	return normalize(norm);
}


vec4 light_point(vec3 pos, int steps) {
	vec4 col = get_voxel(pos);
	vec3 norm = get_normal(pos);
	float sun_light = clamp(dot(norm, normalize(sun_pos)), 0, 1);
	sun_light = max(sun_light, 0.0);
	sun_light = sun_light*0.4+0.1;
	col.rgb *= sun_light;
	//col.rgb = norm*0.5+0.5;
	//col.rgb += vec3(float(steps)/512.);
	return col;
}

void plane_march(in vec3 ray_start, in vec3 ray_dir, out vec3 hit_point, out int steps, out float dist, out bool hit) {
	float ray_len = 0.;
	steps = 0;
	vec3 p;
	while (ray_len <= 100.0 && steps < 512 && p == clamp(p, -0.1, 64.1)) {
		steps++;
		p = ray_start + ray_len * ray_dir;
		float solid = get_voxel(p).a;
		if (solid > 0.) {
			hit_point = p;
			hit = true;
			dist = ray_len;
			return;
		}
		
		vec3 deltas = (step(0, ray_dir) - fract(world_to_voxel(p))) / ray_dir;
		deltas *= voxel_size;
		ray_len += max(mincomp(deltas), 0.0001);
	}
	hit = false;
	dist = ray_len;
	return;
}

float shadow(vec3 pos, vec3 sun_dir) {
	vec3 hit_point;
	int steps;
	float dist;
	bool hit;
	plane_march(pos + sun_dir*0.01, sun_dir, hit_point, steps, dist, hit);
	//float shadow = float(steps)/10.;
	float shadow = 1. - float(hit)*0.7;
	return shadow;
}

void fragment() {
	vec3 surface_pos = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 cam_pos = CAMERA_MATRIX[3].xyz;
	vec3 ray_dir = normalize(surface_pos - cam_pos);
	vec3 ray_start = cam_pos + float(FRONT_FACING)*(surface_pos-cam_pos);
	
	vec3 hit_point;
	int steps;
	float dist;
	bool hit;
	plane_march(ray_start, ray_dir, hit_point, steps, dist, hit);
	vec4 col = light_point(hit_point, steps);
	//if (steps == 1) col *= vec4(1,.1,.1,1);
	ALBEDO = col.rgb * shadow(hit_point, normalize(sun_pos));
	if (!hit) {
		discard;
	}
}
