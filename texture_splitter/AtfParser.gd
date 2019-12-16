extends Reference
class_name AtfParser

var version:int = 0
var format:int = 0
var length:int = 0
var width:int = 0
var height:int = 0
var count:int = 0

func parse(file:File):
	var signature = file.get_buffer(3)
	if not signature.get_string_from_ascii() == "ATF":
		print('File is not an ATF file')
		return null
	
	# reserved
	file.get_32()
	
	version = file.get_8()
	length = file.get_32()
	
	format = file.get_8()
	var is_cubemap = format >> 7 == 1
	if is_cubemap:
		print('Cubemap not supported')
		return null
	format = format & 0x7F
	if not format == 5:
		print('Format not supported')
		return null
		
	width = 1 << file.get_8()
	height = 1 << file.get_8()
	count = file.get_8()
	
	print('Read texture format %s count %s size %sx%s length %s' % [format, count, width, height, length])
	var l = file.get_32()
	var data = file.get_buffer(l * 256)
	var img = Image.new()
	img.create_from_data(width, height, false, Image.FORMAT_DXT5, data)
	
	return img
	
func save(data:PoolByteArray, width:int, height:int, target:String):
	var file = File.new()
	if file.open(target, File.WRITE) == OK:
		# signature
		file.store_string("ATF")
		# reserved
		file.store_32(0xFF020000)
		# version
		file.store_8(0x02)
		# length TODO
		file.store_32(data.size() - 6)
		# format
		file.store_8(0x5)
		# width
		var w = int(log(width)/log(2))
		file.store_8(w)
		# height
		var h = int(log(height)/log(2))
		file.store_8(h)
		# count
		file.store_8(0xB)
		
		# data len TODO
		file.store_32(data.size() / 256)
		# data
		file.store_buffer(data)
		
		# I'm not really sure where this comes from
		var tmp = PoolByteArray()
		tmp.resize(0x81)
		for i in 0x81:
			tmp.set(i, 0x00)
		
		file.store_buffer(tmp)
		
		file.close()
