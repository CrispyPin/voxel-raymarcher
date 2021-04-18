extends MeshInstance


func _ready():
	var voxels = Texture3D.new()
	voxels.create(32, 32, 32, Image.FORMAT_RGBA8)
	voxels.flags = 0
	var block = Image.new()
	block.create(1, 1, false, Image.FORMAT_RGBA8)
	block.lock()
	block.set_pixel(0, 0, Color(0.1,0.5,0.7,1))
	var empty = Image.new()
	empty.create(1, 1, false, Image.FORMAT_RGBA8)
	empty.lock()
	empty.set_pixel(0, 0, Color(0,0,0,0))
	for x in range(32):
		for y in range(32):
			for z in range(32):
				if randf() > 0.96 and x in range(2,30) and y in range(2,30) and z in range(2,30):
					voxels.set_data_partial(block, x, y, z)
				else:
					voxels.set_data_partial(empty, x, y, z)
	get_surface_material(0).set_shader_param("voxels", voxels)
