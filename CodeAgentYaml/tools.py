import os

def write_to_disk(filename: str, content: str) -> str:
    """Writes the given content to a file with the specified filename.
    Creates any necessary parent directories.

    Args:
        filename: The name of the file to write to.
        content: The content to write to the file.
    """
    directory = os.path.dirname(filename)
    if directory:
        os.makedirs(directory, exist_ok=True)
    with open(filename, "w") as f:
        f.write(content)
    return f"Successfully wrote to {filename}"
