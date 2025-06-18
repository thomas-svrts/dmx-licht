#ifndef SIUDI_H
#define SIUDI_H

int siudi_open(void);
void siudi_close(void);
int siudi_send_dmx(const unsigned char *dmx_data);

#endif
