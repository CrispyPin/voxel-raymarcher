extends MeshInstance

var voxels = Texture3D.new()
var _voxel = Image.new()

func _ready():
	voxels.create(32, 32, 32, Image.FORMAT_RGBA8, 0)
	_voxel.create(1, 1, false, Image.FORMAT_RGBA8)
	
	_voxel.lock()
	_fill_raw(Color(0,0,0,0))
	
	for x in range(32):
		for z in range(32):
			set_raw(x, 0, z, Color(x/32.0,z/32.0, randf()*0.25+0.25, 1))
			set_raw(x, 31, z, Color(x/32.0,z/32.0, randf()*0.25+0.25, 1))
			if randf() < 0.4:
				set_raw(x, 1, z, Color(randf(), randf(), randf(), 1))
			if randf() < 0.05:
				set_raw(x, 2, z, Color(randf(), randf(), randf(), 1))
	
	set_raw(8,8,8, Color(randf(), randf(), randf(), 1))
			
	get_surface_material(0).set_shader_param("voxels", voxels)

func _process(_delta):
	#set_raw(5,5,5,Color(1,1,0,1))
	pass

func _fill_raw(col):
	_voxel.set_pixel(0, 0, col)
	for x in range(32):
		for y in range(32):
			for z in range(32):
				voxels.set_data_partial(_voxel, x, y, z)

func set_raw(x, y, z, col):
	_voxel.set_pixel(0, 0, col)
	voxels.set_data_partial(_voxel, x, y, z)
	
