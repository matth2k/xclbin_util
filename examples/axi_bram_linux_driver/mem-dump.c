#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>

#define AXI_INPUT 0xA0000000
#define AXI_HUFF 0xA0002000
#define AXI_HIST 0xA0004000
#define AXI_RESULT 0xA0006000
#define AXI_RST 0xA0010000

#define MAP_SIZE 0x2000
#define MAP_MASK 0x1FFF

#define HIST_LEN 256
#define RESULT_LEN 512

#define PRINT printf

uint32_t axi_hist[256];
uint32_t axi_results[1024];

void extractAxi(unsigned int *hist, unsigned int *results, int hlen, int rlen)
{
    PRINT("Read histogram through axi...\n");
    for (int i = 0; i < hlen; i++)
    {
#ifdef VERBOSE_AXI
        PRINT(".");
#endif
        axi_hist[i] = *(hist + i);
    }

    PRINT(" Read results through axi...\n");
    for (int i = 1; i <= rlen; i++)
    {
#ifdef VERBOSE_AXI
        PRINT(".");
#endif
        axi_results[i] = *(results + i);
    }
    PRINT("  finish extractAxi\n");
}

void printAxi()
{
    printf("Histogram: \n");
    for (int i = 0; i < HIST_LEN; i++)
    {
        printf("%X, ", axi_hist[i]);
    }
    printf("Results: \n");
    for (int i = 0; i < RESULT_LEN; i++)
    {
        printf("%X, ", axi_results[i]);
    }
}

void clrHuff(unsigned int *huffRegs)
{
    PRINT("Resetting huffman...\n");
    *huffRegs = 1;
    *huffRegs = 0;
}

// This routine is overkill, huffman is always done when n=0 (obviously due to the time required for the PRINT)
// But, it may be done when n=0 even without the print, haven't tested that.
void waitHuff(unsigned int *huffRegs)
{
    PRINT("\nWaiting for done ");
    int n = 0;
    while (*(huffRegs + 1) == 0)
    {
        n++;
        if (n % 1000 == 0)
            PRINT(".");
        if (n > 100000)
        {
            PRINT("\n  Failed to get done, aborting.\n");
            return;
        }
    }
    PRINT("\n  Success, received done in %d tries\n", n);
}

int main()
{
    int memfd;
    void *rst_base, *hist_base, *results_base;
    off_t off_rst = AXI_RST;
    off_t off_hist = AXI_HIST;
    off_t off_results = AXI_RESULT;

    memfd = open("/dev/mem", O_RDWR | O_SYNC);
    if (memfd == -1)
    {
        printf("Can't open /dev/mem.\n");
        exit(0);
    }
    printf("/dev/mem opened for reg.\n");

    rst_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, off_rst & ~MAP_MASK);
    if (rst_base == (void *)-1)
    {
        printf("Can't map the memory to user space.\n");
        exit(0);
    }
    printf("rst mem is in user space.\n");

    printf("Resetting encoder\n");
    clrHuff((unsigned int *)rst_base);
    waitHuff((unsigned int *)rst_base);

    if (munmap(rst_base, MAP_SIZE) == -1)
    {
        printf("Can't unmap memory from user space.\n");
        exit(0);
    }

    hist_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, off_hist & ~MAP_MASK);
    if (hist_base == (void *)-1)
    {
        printf("Can't map the memory to user space.\n");
        exit(0);
    }
    printf("hist mem is in user space.\n");

    results_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, off_results & ~MAP_MASK);
    if (results_base == (void *)-1)
    {
        printf("Can't map the memory to user space.\n");
        exit(0);
    }
    printf("hist mem is in user space.\n");


    
    extractAxi((unsigned int *)hist_base, (unsigned int *)results_base, HIST_LEN, RESULT_LEN);
    printAxi();
    
    if (munmap(hist_base , MAP_SIZE) == -1)
    {
        printf("Can't unmap memory from user space.\n");
        exit(0);
    }

    if (munmap(results_base, MAP_SIZE) == -1)
    {
        printf("Can't unmap memory from user space.\n");
        exit(0);
    }

    close(memfd);

    printf("Done!");
    return 0;
}