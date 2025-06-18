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

bool open_device_sequence() {
    unsigned char buf[1024] = {0};
    send_control(0xC0, 33, 0x0000, 1, buf, 1, 100, "open: probe 1");
    send_control(0xC0, 33, 0x0000, 0, buf, 64, 100, "open: probe 2");
    send_control(0xC0, 33, 0x0001, 0, buf, 64, 100, "open: probe 3");

    unsigned char dat[128] = {
        0xd4, 0xf5, 0x15, 0x82, 0x12, 0x37, 0x99, 0x4f, 0x10, 0xbf, 0x34, 0xdd, 0x9b, 0x00, 0x0a, 0x74,
        0x2a, 0xe5, 0xbe, 0x7c, 0xe1, 0xac, 0x72, 0xe4, 0x8a, 0xe7, 0xd0, 0x75, 0x9b, 0x79, 0xec, 0xb0,
        0x61, 0xb5, 0x07, 0xdf, 0x27, 0x11, 0x90, 0xef, 0xdc, 0x9b, 0x0c, 0x36, 0x8f, 0xb8, 0x0b, 0xc0,
        0x82, 0x34, 0x66, 0x6c, 0xc5, 0x9b, 0x88, 0xd7, 0x78, 0x23, 0x2a, 0x74, 0x9f, 0x3b, 0xbe, 0xb7,
        0x4b, 0x44, 0x7c, 0x9d, 0xe1, 0x70, 0xf8, 0xec, 0x4a, 0x13, 0x74, 0x1d, 0xfe, 0x03, 0xce, 0x91,
        0xb3, 0x74, 0xff, 0xf2, 0x0f, 0x34, 0x2e, 0xb2, 0x40, 0xb1, 0x67, 0x26, 0xa8, 0x52, 0x79, 0x3b,
        0xf4, 0x79, 0x37, 0xb8, 0xbf, 0xf7, 0x79, 0x48, 0x61, 0xaf, 0xa9, 0xf5, 0x52, 0x2a, 0xbb, 0x39,
        0x98, 0xd8, 0xd8, 0x78, 0x49, 0xde, 0x80, 0x63, 0x75, 0x44, 0xd0, 0xd3, 0xbd, 0x5d, 0x61, 0x86
    };
    send_control(0x40, 33, 0x0000, 0, dat, 128, 100, "open: blob");
    send_control(0xC0, 33, 0x0000, 1, buf, 1, 100, "open: blob confirm");
    send_control(0x40, 6, 0x0002, 0, buf, 0, 100, "open: trigger?");
    send_control(0xC0, 2, 0x0000, 0, buf, 64, 100, "open: memory read");

    return true;
}

bool setup_device_sequence() {
    unsigned char ans[512] = {0};
    ans[0] = 1; // universe
    send_control(0x40, 48, 0xffff, 0, ans, 0, 100, "setup: set universe");
    send_control(0x40, 17, 0x0001, 0, ans, 0, 100, "setup: DMX init");
    send_control(0xC0, 33, 0x0000, 1, ans, 1, 100, "setup: status");
    send_control(0x40, 33, 0x0000, 1, ans, 1, 100, "setup: confirm");

    return true;
}

bool send_dmx_packet() {
    unsigned char dmx[DMX_CHANNELS] = {0};
    dmx[0] = 128;

    unsigned char ans[1] = {0};
    send_control(0xC0, 33, 0x0000, 1, ans, 1, 100, "pre-send status");

    log_time();
    printf("Sending DMX via BULK endpoint 0x02 in 64-byte chunks...\n");

    int total_sent = 0;
    for (int i = 0; i < DMX_CHANNELS; i += 64) {
        int transferred = 0;
        int len = (DMX_CHANNELS - i >= 64) ? 64 : (DMX_CHANNELS - i);
        int rc = libusb_bulk_transfer(handle, 0x02, dmx + i, len, &transferred, 1000);
        usleep(50000);
        if (rc != 0) {
            log_time();
            fprintf(stderr, "❌ BULK chunk %d failed: %s\n", i / 64, libusb_strerror(rc));
            return false;
        }
        log_time();
        printf("✅ BULK chunk %d sent: %d bytes\n", i / 64, transferred);
        total_sent += transferred;
    }

    log_time();
    printf("✅ All DMX chunks sent (%d bytes total)\n", total_sent);
    dump_bytes("First 64 bytes of DMX Packet", dmx, 64);
    return true;
}

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
    if (!send_dmx_packet()) { shutdown_usb(); return 1; }
    usleep(300000); // kleine vertraging
    shutdown_usb();
    return 0;
}
