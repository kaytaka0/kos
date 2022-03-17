#pragma once

#include <cstdint>
#include <array>

#include "error.hpp"

namespace pci {
    // CONFIG_ADDRSS レジスタのIOポートアドレス
    const uint16_t kConfigAddress = 0xcf8;
    // CONFIG_DATA レジスタのIOポートアドレス
    const uint16_t kConfigData = 0xcfc;

    struct ClassCode {
        uint8_t base, sub, interface;

        // ベースクラスが等しい場合に真
        bool Match(uint8_t b) {return b == base;}
        // ベース、サブが等しい場合に真
        bool Match(uint8_t b, uint8_t s) { return Match(b) && s == sub;}
        // ベース、サブ、インターフェイスが等しい場合に真
        bool Match(uint8_t b, uint8_t s, uint8_t i) {
            return Match(b, s) && i == interface;
        }
    };

    struct Device {
        uint8_t bus, device, function, header_type;
        ClassCode class_code;

    };

    void WriteAddress(uint32_t address);
    void WriteData(uint32_t value);

    uint16_t ReadVendorId(uint8_t bus, uint8_t device, uint8_t function);
    uint16_t ReadDeviceId(uint8_t bus, uint8_t device, uint8_t function);
    uint8_t ReadHeaderType(uint8_t bus, uint8_t device, uint8_t function);
    ClassCode ReadClassCode(uint8_t bus, uint8_t device, uint8_t function);

    inline uint16_t ReadVendorId(const Device& dev) {
        return ReadVendorId(dev.bus, dev.device, dev.function);
    }


    uint32_t ReadConfReg(const Device& dev, uint8_t reg_addr);

    void WriteConfReg(const Device& dev, uint8_t reg_addr, uint32_t value);

    /** @brief バス番号レジスタを読み取る（ヘッダタイプ 1 用）
     *
     * 返される 32 ビット整数の構造は次の通り．
     *   - 23:16 : サブオーディネイトバス番号
     *   - 15:8  : セカンダリバス番号
     *   - 7:0   : リビジョン番号
     */
    uint32_t ReadBusNumbers(uint8_t bus, uint8_t device, uint8_t function);

    /** @brief 単一ファンクションの場合に真を返す． */
    bool IsSingleFunctionDevice(uint8_t header_type);

    inline std::array<Device, 32> devices;
    inline int num_device;

    // Bus 0 から再帰的にPCIデバイスを探索し、
    // devicesの先頭から格納する
    // 発見したデバイスの数を　num_devices に格納する
    Error ScanAllBus();

    constexpr uint8_t CalcBarAddress(unsigned int bar_index) {
        return 0x10 + 4 * bar_index;
    }

    WithError<uint64_t> ReadBar(Device& device, unsigned int bar_index);
}