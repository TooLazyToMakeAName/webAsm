//
// Created by sweetsleep on 3/25/19.
//

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


int main(int argc, char *argv[]) {
    char *addr;
    int fd;
    struct stat sb;
    off_t offset, pa_offset;
    size_t length = 0;
    ssize_t s;

    printf("%d\n", sizeof(sb.st_dev));
    printf("%d\n", sizeof(sb.st_ino));
    printf("%d\n", sizeof(sb.st_mode));
    printf("%d\n", sizeof(sb.st_nlink));
    printf("%d\n", sizeof(sb.st_uid));
    printf("%d\n", sizeof(sb.st_gid));
    printf("%d\n", sizeof(sb.st_rdev));
    printf("%d\n", sizeof(sb.st_size));
    printf("%d\n", sizeof(sb.st_blksize));
    printf("%d\n", sizeof(sb.st_blocks));
    printf("%d\n", sizeof(sb.st_atim));
    printf("%d\n", sizeof(sb.st_mtim));
    printf("%d\n", sizeof(sb.st_ctim));
    printf("%d\n", sizeof(sb.));


    int tot = sizeof(sb.st_dev) +
              sizeof(sb.st_ino) +
              sizeof(sb.st_mode) +
              sizeof(sb.st_nlink) +
              sizeof(sb.st_uid) +
              sizeof(sb.st_gid) +
              sizeof(sb.st_rdev) +
              sizeof(sb.st_size) +
              sizeof(sb.st_blksize) +
              sizeof(sb.st_blocks) +
              sizeof(sb.st_atim) +
              sizeof(sb.st_mtim) +
              sizeof(sb.st_ctim);
    printf("%d",tot);


    fd = open("Makefile", O_RDONLY);

    fstat(fd, &sb);
    length += sb.st_size;


    addr = mmap(NULL, length, PROT_READ,
                MAP_PRIVATE, fd, 0);

    for (int i = 0; i < 4820; ++i) {
        //printf("%c", addr[i]);
    }

    munmap(addr, length);
    close(fd);

    exit(EXIT_SUCCESS);
}