#pragma once

#include <deque>
#include <map>
#include "window.hpp"
#include "task.hpp"
#include "layer.hpp"

class Terminal {
public:
    static const int kRow = 15;
    static const int kColumns = 60;
    static const int kLineMax = 128;

    Terminal();
    unsigned int LayerId() const { return layer_id_; }
    Rectangle<int> BlinkCursor();
    Rectangle<int> InputKey(uint8_t modifier, uint8_t keycode, char ascii);

private:
    std::shared_ptr<ToplevelWindow> window_;
    unsigned int layer_id_;

    Vector2D<int> cursor_{0, 0};
    bool cursor_visible_{false};
    void DrawCursor(bool visible);
    Vector2D<int> CalcCursorPos() const;
    
    int linebuf_index_{0};
    std::array<char, kLineMax> linebuf_{};
    void Scroll1();
    void Print(const char* s);
    void Print(char c);
    void ExecuteLine();
    
    std::deque<std::array<char, kLineMax>> cmd_history_{};
    int cmd_history_index_{-1};
    Rectangle<int> HistoryUpDown(int direction);
};
    
void TaskTerminal(uint64_t task_id, int64_t data);
