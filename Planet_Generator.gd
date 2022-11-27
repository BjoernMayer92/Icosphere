extends Spatial

var vertices_icosahedron_faces = []
var number_of_faces_in_icosahedron = 20

func generate_icosahedron_mesh():
	var t = (1.0 + sqrt(5))/2
	var vertices = PoolVector3Array()
	var faces = []

	
	# Define Array for mesh
	var array = []
	array.resize(ArrayMesh.ARRAY_MAX)
	
	# Define Vertices
	vertices.append(Vector3(-1,t,0).normalized())
	vertices.append(Vector3(1,t,0).normalized())
	vertices.append(Vector3(-1,-t,0).normalized())
	vertices.append(Vector3(1,-t,0).normalized())
	vertices.append(Vector3(0,-1,t).normalized())
	vertices.append(Vector3(0,1,t).normalized())
	vertices.append(Vector3(0,-1,-t).normalized())
	vertices.append(Vector3(0,1,-t).normalized())
	vertices.append(Vector3(t,0,-1).normalized())
	vertices.append(Vector3(t,0,1).normalized())
	vertices.append(Vector3(-t,0,-1).normalized())
	vertices.append(Vector3(-t,0,1).normalized())
	
	# Define Faces
	faces.append([5, 11, 0])
	faces.append([1, 5, 0])
	faces.append([7, 1, 0])
	faces.append([10, 7, 0])
	faces.append([11, 10, 0])
	faces.append([9, 5, 1])
	faces.append([4, 11, 5])
	faces.append([2, 10, 11])
	faces.append([6, 7, 10])
	faces.append([8, 1, 7])
	faces.append([4, 9, 3])
	faces.append([2, 4, 3])
	faces.append([6, 2, 3])
	faces.append([8, 6, 3])
	faces.append([9, 8, 3])
	faces.append([5, 9, 4])
	faces.append([11, 4, 2])
	faces.append([10, 2, 6])
	faces.append([7, 6, 8])
	faces.append([1, 8, 9])
	
	
	var normals = PoolVector3Array()
	for vertex in vertices:
		normals.push_back(vertex.normalized())
	
	# Fill in Array

	
	return [vertices, faces]
	
func cal_middle_point(point_1, point_2):
	return 0.5*point_1+0.5*point_2
	
# Called when the node enters the scene tree for the first time.

func divide_face(face, icosahedron_face_index, current_subdivision):
	var sub_vertices = PoolVector3Array()
	var sub_faces_indices = []
	var sub_colors = PoolColorArray()
	var array = []
	
	array.resize(ArrayMesh.ARRAY_MAX)
	
	sub_vertices.append(face[0].normalized())
	sub_vertices.append(cal_middle_point(face[0],face[1]).normalized())
	sub_vertices.append(face[1].normalized())
	
	sub_vertices.append(cal_middle_point(face[1],face[2]).normalized())
	sub_vertices.append(face[2].normalized())
	
	sub_vertices.append(cal_middle_point(face[2],face[0]).normalized())

	
	sub_colors.append(Color(1,0,0,1))
	sub_colors.append(Color(0,0,1,1))
	sub_colors.append(Color(0,1,0,1))
	sub_colors.append(Color(1,1,0,1))
	sub_colors.append(Color(1,0,1,1))
	sub_colors.append(Color(0,1,1,1))

	sub_faces_indices.append([0,1,5])
	sub_faces_indices.append([1,2,3])
	sub_faces_indices.append([3,4,5])
	sub_faces_indices.append([1,3,5])
	
	if current_subdivision==0:
		for sub_face_indices in sub_faces_indices:
			
			vertices_icosahedron_faces[icosahedron_face_index].append(sub_vertices[sub_face_indices[0]])
			vertices_icosahedron_faces[icosahedron_face_index].append(sub_vertices[sub_face_indices[1]])
			vertices_icosahedron_faces[icosahedron_face_index].append(sub_vertices[sub_face_indices[2]])

	else:
		for sub_face_indices in sub_faces_indices:
			var sub_face = PoolVector3Array()
			sub_face.append(sub_vertices[sub_face_indices[0]])
			sub_face.append(sub_vertices[sub_face_indices[1]])
			sub_face.append(sub_vertices[sub_face_indices[2]])
			
			divide_face(sub_face,  icosahedron_face_index, current_subdivision-1)
	
	return array
	


func _ready():
	vertices_icosahedron_faces.resize(number_of_faces_in_icosahedron)
	for icosahedron_face_index in number_of_faces_in_icosahedron:
		vertices_icosahedron_faces[icosahedron_face_index]=[]
	
	# Generate Icosahedron
	var icosahedron_array= generate_icosahedron_mesh()

	# Subdivide Individual Faces
	var icosahedron_vertices = icosahedron_array[0]
	var icosahedron_vertices_indices_faces = icosahedron_array[1]
	
	var face_mesh_instances = []
	
	for icosahedron_face_index in icosahedron_vertices_indices_faces.size():
		# Get Face
		var icosahedron_face = PoolVector3Array()
		for icosahedron_vertices_index in icosahedron_vertices_indices_faces[icosahedron_face_index]:
			icosahedron_face.append(icosahedron_vertices[icosahedron_vertices_index])
		
		# Divide Face
		divide_face(icosahedron_face, icosahedron_face_index,2)
		
		# Add Face to scene
		var icosahedron_face_array = []
		var icosahedron_face_array_mesh = ArrayMesh.new()	
		var icosahedron_face_meshinstance = MeshInstance.new()
		
		icosahedron_face_array.resize(ArrayMesh.ARRAY_MAX)
		icosahedron_face_array[ArrayMesh.ARRAY_VERTEX] = vertices_icosahedron_faces[icosahedron_face_index]
	
		icosahedron_face_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, icosahedron_face_array)
		icosahedron_face_meshinstance.mesh = icosahedron_face_array_mesh
		
		face_mesh_instances.append(icosahedron_face_meshinstance)
		add_child(icosahedron_face_meshinstance)
	
