## Project knowledge

- Local imports now accept EPUB and TXT files; PDF support was removed.
- HomeScreenSmall uses FilePicker with EPUB/TXT allowedExtensions and shows an UnsupportedError message if an unsupported type is chosen.
- LocalLibraryRepository filters stored books to supported types (currently EPUB and TXT) and throws UnsupportedError for unsupported file types during import.
