#include <libusb-1.0/libusb.h>
#include <stdio.h>
#include <string.h>

static libusb_device_handle *dev_handle = NULL;

int siudi_open(void) {
    libusb_init(NULL);
    dev_handle = libusb_open_device_with_vid_pid(NULL, 0x6244, 0x0591);
    if (!dev_handle) return -1;

    if (libusb_kernel_driver_active(dev_handle, 0) == 1)
        libusb_detach_kernel_driver(dev_handle, 0);

    libusb_claim_interface(dev_handle, 0);
    return 0;
}

void siudi_close(void) {
    if (dev_handle) {
        libusb_release_interface(dev_handle, 0);
        libusb_close(dev_handle);
        libusb_exit(NULL);
        dev_handle = NULL;
    }
}

int siudi_send_dmx(const unsigned char *dmx_data) {
    unsigned char buffer[520];
    int transferred;

    memset(buffer, 0, sizeof(buffer));
    buffer[0] = 0x00; // command?
    buffer[1] = 0x01; // subcommand?
    memcpy(buffer + 8, dmx_data, 512);

    return libusb_bulk_transfer(dev_handle, 0x02, buffer, sizeof(buffer), &transferred, 1000);
}
