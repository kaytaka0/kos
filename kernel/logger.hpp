#pragma once

enum LogLevel {
    kError = 3,
    kWarn = 4,
    kInfo = 5,
    kDebug = 6,
};

void SetLogLevel(LogLevel level);

int Log(LogLevel level, const char* format, ...);