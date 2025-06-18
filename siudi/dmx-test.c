#include <stdio.h>
#include <stdlib.h>
#include "siudi.h"

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Gebruik: %s kanaal waarde\n", argv[0]);
        return 1;
    }

    int kanaal = atoi(argv[1]);
    int waarde = atoi(argv[2]);

    if (kanaal < 1 || kanaal > 512 || waarde < 0 || waarde > 255) {
        fprintf(stderr, "❌ Ongeldige input. Kanaal 1-512, waarde 0-255.\n");
        return 1;
    }

    if (siudi_open() != 0) {
        fprintf(stderr, "❌ Kon de SIUDI dongle niet openen.\n");
        return 1;
    }

    unsigned char data[512] = {0};
    data[kanaal - 1] = waarde;

    siudi_send_dmx(data);
    siudi_close();

    printf("✅ Kanaal %d ingesteld op %d.\n", kanaal, waarde);
    return 0;
}
