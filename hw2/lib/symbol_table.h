#ifndef __SYMBOL_TABLE_H
#define __SYMBOL_TABLE_H

#ifdef __cplusplus
extern "C"
{
#endif
    // If failed return -1, else 0
    int insert(const char *_token);

    void push();
    void pop();
#ifdef __cplusplus
}
#endif

#endif