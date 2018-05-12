#include <shell>

enum Test {
  Float:vec3[3],  
  Float:vec2[2]
};

public void main() {
  int test[Test];
  float vec[3];
  Handle hFile;
  WriteFile(hFile, test[vec3], 3, 4); // warning: tag mismatch but works
  WriteFile(hFile, _:test[vec3], 3, 4); // All fine
  WriteFile(hFile, view_as<int>(vec), 3, 4);
  WriteFile(hFile, view_as<int>(test[vec3]), 3, 4); // Writes random memory
}
