#pragma once

#include <cstdint>
#include <queue>
#include <vector>
#include <limits>

#include "acpi.hpp"
#include "message.hpp"

void InitializeLAPICTimer();
void StartLAPICTimer();
uint32_t LAPICTimerElapsed();
void StopLAPICTimer();

class Timer {
  public:
  Timer(unsigned long timeout, int value);
  unsigned long Timerout() const { return timeout_; }
  int Value() const { return value_; }

  private:
  unsigned long timeout_;
  int value_;
};

// Timerの優先度: タイムアウトが小さいTimerの方が優先度が高い．
inline bool operator<(const Timer& lhs, const Timer& rhs) {
  return lhs.Timerout() > rhs.Timerout();
}

class TimerManager {
  public:
  TimerManager();
  void AddTimer(const Timer& timer);
  bool Tick();
  unsigned long CurrentTick() const {return tick_;}

  private:
  volatile unsigned long tick_{0};
  std::priority_queue<Timer> timers_{};
};

extern TimerManager* timer_manager;
extern unsigned long lapic_timer_freq;
const int kTimerFreq = 100;

const int kTaskTimerPeriod = static_cast<int>(kTimerFreq * 0.02);
const int kTaskTimerValue = std::numeric_limits<int>::min();

void LAPICTimerOnInterrupt();