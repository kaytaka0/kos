#pragma once

#include <array>
#include <limits>

#include "error.hpp"
#include "memory_map.hpp"

namespace
{
    constexpr unsigned long long operator""_KiB(unsigned long long kib)
    {
        return kib * 1024;
    }

    constexpr unsigned long long operator""_MiB(unsigned long long mib)
    {
        return mib * 1024_KiB;
    }

    constexpr unsigned long long operator""_GiB(unsigned long long gib)
    {
        return gib * 1024_MiB;
    }
}

static const auto kBytesPerFrame{4_KiB};

class FrameID
{
public:
    explicit FrameID(size_t id) : id_{id} {};
    size_t ID() const { return id_; }

private:
    size_t id_;
};

static const FrameID kNullFrame{std::numeric_limits<size_t>::max()};

class BitmapMemoryManager
{
public:
    // このメモリ管理クラスで扱える最大の物理メモリ量（バイト）
    static const auto kMaxPhysicalMemoryBytes{128_GiB};
    // kMaxPhysicalMemoryBytesまでのブル地メモリを扱うために必要なフレーム数
    static const auto kFrameCount{kMaxPhysicalMemoryBytes / kBytesPerFrame};

    using MapLineType = unsigned long;
    static const size_t kBitsPerMapLine{8 * sizeof(MapLineType)};

    BitmapMemoryManager();

    WithError<FrameID> Allocate(size_t num_frames);
    Error Free(FrameID start_frame, size_t num_frames);
    void MarkAllocated(FrameID start_frame, size_t num_frames);

    /**
     * @brief  * このメモリマネージャで扱うメモリ範囲を設定する
     * この呼び出し以降、Allocateによるメモリ割り当ては設定された範囲内でのみ行われる
     * @param range_begin_ メモリ範囲の始点
     * @param range_end_   メモリ範囲の終点、最終フレームの次のフレーム
     */
    void SetMemoryRange(FrameID range_begin, FrameID range_end);

private:
    std::array<MapLineType, kFrameCount / kBitsPerMapLine> alloc_map_;
    FrameID range_begin_;
    FrameID range_end_;

    bool GetBit(FrameID frame) const;
    void SetBit(FrameID frame, bool allocated);
};

void InitializeMemoryManager(const MemoryMap& memory_map);
