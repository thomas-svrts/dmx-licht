#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <libusb-1.0/libusb.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>

#define VENDOR_ID  0x6244
#define PRODUCT_ID 0x0591
#define DMX_CHANNELS 512

libusb_context* ctx = NULL;
libusb_device_handle* handle = NULL;

void log_time() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    struct tm* tm_info = localtime(&tv.tv_sec);
    char buffer[64];
    strftime(buffer, 64, "%Y-%m-%d %H:%M:%S", tm_info);
    printf("[%s.%03ld] ", buffer, tv.tv_usec / 1000);
}

void dump_bytes(const char* label, const unsigned char* data, int len) {
    if (!data || len <= 0) return;
    log_time();
    printf("%s (%d bytes):\n", label, len);
    for (int i = 0; i < len; i++) {
        if (i % 16 == 0) printf("  ");
        printf("%02X ", data[i]);
        if ((i + 1) % 16 == 0 || i == len - 1) printf("\n");
    }
}

void decode_bmRequestType(uint8_t bm) {
    const char* dir = (bm & 0x80) ? "IN" : "OUT";
    const char* type = (bm & 0x60) == 0x00 ? "Standard" :
                       (bm & 0x60) == 0x20 ? "Class" :
                       (bm & 0x60) == 0x40 ? "Vendor" : "Reserved";
    const char* recip = (bm & 0x1F) == 0x00 ? "Device" :
                        (bm & 0x1F) == 0x01 ? "Interface" :
                        (bm & 0x1F) == 0x02 ? "Endpoint" : "Other";

    printf("  bmRequestType: 0x%02X (%s | %s | %s)\n", bm, dir, type, recip);
}

const char* decode_request(uint8_t req) {
    switch (req) {
        case 6: return "RESET / STOP?";
        case 17: return "INIT DMX OUT?";
        case 33: return "DEVICE STATUS";
        case 48: return "SET UNIVERSE";
        default: return "UNKNOWN";
    }
}

bool send_control(uint8_t bm, uint8_t req, uint16_t wVal, uint16_t wIdx,
                  unsigned char* data, uint16_t len, unsigned int timeout, const char* label) {
    log_time();
    printf("CONTROL [%s] bRequest=0x%02X (%s)\n", label, req, decode_request(req));
    decode_bmRequestType(bm);
    printf("  wValue: 0x%04X | wIndex: 0x%04X | length: %d | timeout: %d ms\n", wVal, wIdx, len, timeout);

    if ((bm & 0x80) == 0 && data && len > 0)
        dump_bytes("  Data OUT", data, len);

    int rc = libusb_control_transfer(handle, bm, req, wVal, wIdx, data, len, timeout);
    usleep(50000); // 50 ms vertraging tussen alle transfers

    if (rc < 0 && rc != LIBUSB_ERROR_PIPE) {
        log_time(); fprintf(stderr, "  ❌ Control transfer FAILED: %s\n", libusb_strerror(rc));
        return false;
    }

    log_time(); printf("  ✅ Control transfer SUCCESS (%d bytes transferred)\n", rc);
    if ((bm & 0x80) && data && rc > 0)
        dump_bytes("  Data IN", data, rc);

    return true;
}

bool init_usb() {
    log_time(); printf("Initializing libusb...\n");
    if (libusb_init(&ctx) != 0) {
        fprintf(stderr, "libusb init failed\n");
        return false;
    }
    handle = libusb_open_device_with_vid_pid(ctx, VENDOR_ID, PRODUCT_ID);
    if (!handle) {
        fprintf(stderr, "Device not found\n");
        return false;
    }

    if (libusb_kernel_driver_active(handle, 0)) {
        log_time(); printf("Detaching kernel driver...\n");
        libusb_detach_kernel_driver(handle, 0);
        usleep(50000);
    }

    if (libusb_claim_interface(handle, 0) != 0) {
        fprintf(stderr, "Cannot claim interface\n");
        return false;
    }

    log_time(); printf("Device interface claimed successfully.\n");
    return true;
}

bool open_device_sequence();
bool setup_device_sequence();
bool send_dmx_packet();

void shutdown_usb() {
    send_control(0x40, 6, 0x0003, 0, NULL, 0, 100, "shutdown");
    if (handle) {
        libusb_release_interface(handle, 0);
        libusb_close(handle);
    }
    libusb_exit(ctx);
    log_time(); printf("Device shutdown complete.\n");
}

int main() {
    printf("\n=== SIUDI ULTRA DEBUG SESSION START ===\n");
    if (!init_usb()) return 1;
    if (!open_device_sequence()) { shutdown_usb(); return 1; }
    if (!setup_device_sequence()) { shutdown_usb(); return 1; }
    usleep(200000); // extra vertraging vóór eerste bulk transfer
    if (!send_dmx_packet()) { shutdown_usb(); return 1; }
    usleep(300000); // kleine vertraging
    shutdown_usb();
    return 0;
}
