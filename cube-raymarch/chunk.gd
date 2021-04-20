extends MeshInstance

export var voxel_count = 64
export var voxel_size = 0.5#0.03125
var chunk_size = voxel_count * voxel_size;

var voxels = Texture3D.new()
var _voxel = Image.new()

func _ready():
	voxels.create(voxel_count, voxel_count, voxel_count, Image.FORMAT_RGBA8, 0)
	_voxel.create(1, 1, false, Image.FORMAT_RGBA8)

	_voxel.lock()
	_fill_raw(Color(0,0,0,0))

	for x in range(voxel_count):
		for z in range(voxel_count):
			set_raw(x, 0, z, Color(x/64.0, z/64.0, 0.5, 1))
			set_raw(x, voxel_count-1, z, Color(x/64.0, z/64.0, 0.5, 1))
			if randf() < 0.4:
				set_raw(x, 1, z, Color(randf(), randf(), randf(), 1))
			if randf() < 0.05:
				set_raw(x, 2, z, Color(randf(), randf(), randf(), 1))

	get_surface_material(0).set_shader_param("voxel_count", voxel_count)
	get_surface_material(0).set_shader_param("voxel_size", voxel_size)
	get_surface_material(0).set_shader_param("chunk_size", chunk_size)
	get_surface_material(0).set_shader_param("voxels", voxels)

func _process(_delta):
	#set_raw(5,5,5,Color(1,1,0,1))
	pass

func _fill_raw(col):
	_voxel.set_pixel(0, 0, col)
	for x in range(voxel_count):
		for y in range(voxel_count):
			for z in range(voxel_count):
				voxels.set_data_partial(_voxel, x, y, z)

func set_raw(x, y, z, col):
	_voxel.set_pixel(0, 0, col)
	voxels.set_data_partial(_voxel, x, y, z)

