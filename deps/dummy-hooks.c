#include <stddef.h>
#include <stdio.h>

void (*FGb_julia_info )(const char* message);
void (*FGb_julia_error)(const char* message);

void info_Maple(const char* s)          { FGb_julia_info(s);  }
void FGb_int_error_Maple(const char* s) { FGb_julia_error(s); }
void FGb_error_Maple(const char* s)     { FGb_julia_error(s); }

void FGb_checkInterrupt() {}

void FGb_int_checkInterrupt() {}

void FGb_push_gmp_alloc_fnct(void *(*alloc_func) (size_t),
                             void *(*realloc_func) (void *, size_t, size_t),
                             void (*free_func) (void *, size_t))
{
}

void FGb_pop_gmp_alloc_fnct() { }
