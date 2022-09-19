#include <cstdio>
void* operator new[](unsigned long, char c) {
    return (void*)123;
}

int main(int argc, char *argv[argc]) {
    fprintf(stderr, argv[0]);
    // fflush(stdout);
    int *array = new('c') int[100];
    // printf(argv[1], array);
    // delete[] array;
    // printf(argv[2]);
    return argc;  // BOOM
}
