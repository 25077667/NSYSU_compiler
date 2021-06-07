---
title: 有關最佳化...舉10個例子
date: 2021-06-07 11:24:51
tags: final_report
author: Chih-Hsuan, Yang
---

1. Pop arguments at once.
For machines that must pop arguments after a function call, always pop the arguments as soon as each function returns. At gcc levels -O1 and higher, -fdefer-pop is the default; this allows the compiler to let arguments accumulate on the stack for several function calls and pop them all at once.

Example:
```C=
int bar(int a, int b, int c) { ... }
int foo(int a, int b, int c) { ... }
int moo(int a, int b, int c) { ... }
int main() {
    bar(1,2,3);
    foo(1,2,3);
    moo(1,2,3);
}
```

Orig: push push push -> pop pop pop -> push push push -> pop pop pop -> push push push -> pop pop pop
Opt: push push push -> push push push -> push push push -> pop pop pop -> pop pop pop -> pop pop pop

2. Optimize sibling and tail recursive calls.

Example:
```C=
int foo(int para){
    if (!para)
        return 1;
    return para * foo(para - 1);
}
```

Orig: Recursion, many many function call.
Opt: Loop
```C=
int res = 1;
for (int i = para; i != 0; i--)
    res *= i;
return res;
```

3. Optimize various standard C string functions (e.g. strlen, strchr or strcpy) and their _FORTIFY_SOURCE counterparts into faster alternatives.
strlen: O(n) -> constant time
strchr: O(n) -> constant time
strncmp: O(n)-> constant time
..

4. inline small functions
Integrate functions into their callers when their body is smaller than expected function call code (so overall size of program gets smaller).
The compiler heuristically decides which functions are simple enough to be worth integrating in this way.
This inlining applies to all functions, even those not declared inline.

Just like the macro, but no side effect.

```C=
#define SQUARE(x) x*x
int main()
{
    printf("%d\n", SQUARE(1+2*3)*SQUARE(3+4*5));
    return 0;
}
```

and

```C=
inline int SQUARE(x) x*x
int main()
{
    printf("%d\n", SQUARE(1+2*3)*SQUARE(3+4*5));
    return 0;
}
```

5. early inlining
In gcc:
Inline functions marked by always_inline and functions whose body seems smaller than the function call overhead early before doing -fprofile-generate instrumentation and real inlining pass. 
Doing so makes profiling significantly cheaper and usually inlining faster on programs having large chains of nested wrapper functions.

Example:
```C=
void terminal(int para) {...}
void wrapper(int para) {... will_go_to_terminal}
int main(){
    wrapper(1);
    return 0;
}
```

Orig: Do the deep call.
Opt: Do the terminal.

6. constexpr
The constexpr specifier declares that it is possible to evaluate the value of the function or variable at compile time. Such variables and functions can then be used where only compile time constant expressions are allowed (provided that appropriate function arguments are given).

Example:
```
constexpr int sq(int n)
{
  return n * n;
}
int main()
{
  constexpr int N = 123;
  constexpr int N_SQ = sq(N);
}
```

Orig: Do it in runtime.
Opt: Do it in compile time.

7. fast math
It can result in incorrect output for programs that depend on an exact implementation of IEEE or ISO rules/specifications for math functions. 
It may, however, yield faster code for programs that do not require the guarantees of these specifications.

Example:
```C=
int n;
int a = n * 65536;
```

Orig: n * 65536
Opt: n << 16

8. Branch prediction
__builtin_expect(long exp, long c)
You can use the __builtin_expect built-in function to indicate that an expression is likely to evaluate to a specified value. The compiler can use this knowledge to direct optimizations. This built-in function is portable with the GNU C/C++ __builtin_expect function.

Example:
```C=
#define likely(x) __builtin_expect(!!(x), 1)
#define unlikely(x) __builtin_expect(!!(x), 0)

if (likely(!active_balance)) {
    /* We were unbalanced, so reset the balancing interval */

    sd->balance_interval = sd->min_interval;
} else {
    /*
    * If we've begun active balancing, start to back off. This
    * case may not be covered by the all_pinned logic if there
    * is only 1 task on the busy runqueue (because we don't call
    * move_tasks).
    */

    if (sd->balance_interval max_interval)
    sd->balance_interval *= 2;
}
```

9. unroll loops
Unroll loops whose number of iterations can be determined at compile time or upon entry to the loop. -funroll-loops implies -frerun-cse-after-loop, -fweb and -frename-registers. It also turns on complete loop peeling (i.e. complete removal of loops with a small constant number of iterations). This option makes code larger, and may or may not make it run faster.

Example:
```C=
int ans = 0;
for(int i = 0; i < 101; i++)
    ans += i;
```

Orig: ans += i; branch; ans += i; branch; ans += i;... 
Opt: ans += i;ans += i;ans += i;ans += i;ans += i;ans += i;...

10. version-loops-for-strides
If a loop iterates over an array with a variable stride, create another version of the loop that assumes the stride is always one. 

Example:
```
for (int i = 0; i < n; ++i)
  x[i * stride] = ...;
```

With optimization becomes:
```
if (stride == 1)
  for (int i = 0; i < n; ++i)
    x[i] = ...;
else
  for (int i = 0; i < n; ++i)
    x[i * stride] = ...;
```