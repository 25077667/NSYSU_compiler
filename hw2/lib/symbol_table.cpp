#include "symbol_table.h"
#include <unordered_set>
#include <string>
#include <vector>

namespace
{
    using Hash_map = std::unordered_set<std::string>;
    Hash_map symbol_table;
    std::vector<Hash_map> stack;
}

int insert(const char *_token)
{
    auto res = -(stack.back().find(_token) == stack.back().end());
    if (!res)
        stack.back().insert(_token);
    return res;
}

void pop()
{
    stack.pop_back();
}

void push()
{
    stack.push_back(Hash_map());
}