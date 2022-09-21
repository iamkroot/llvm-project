#include <cstdio>
void* operator new[](unsigned long, const char* c) {
    printf(c);
    return (void*)123;
}

int main(int argc, char *argv[]) {
    printf(argv[1]);
    // fflush(stdout);
    int *array = new(argv[1]) int[100];
    // printf(argv[1], array);
    // delete[] array;
    // printf(argv[2]);
    return array[5];  // BOOM
}
