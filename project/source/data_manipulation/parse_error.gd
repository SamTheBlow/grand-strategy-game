class_name ParseError
## Different errors that can occur when parsing custom file formats.


enum {
	OK,
	NO_DATA,
	UNSUPPORTED_VERSION,
	CORRUPTED_DATA, # Only use after you already know the format version
}
