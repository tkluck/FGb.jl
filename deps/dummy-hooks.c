#include <stddef.h>
#include <stdio.h>

void info_Maple(const char* s) {fprintf(stderr,"[FGb info ] %s", s);}

void FGb_int_error_Maple(const char* s) {fprintf(stderr,"[FGb error] %s", s);}

void FGb_error_Maple(const char* s)
{
  FGb_int_error_Maple(s);
}

void FGb_checkInterrupt()
{
}

void FGb_int_checkInterrupt()
{
}

void FGb_push_gmp_alloc_fnct(void *(*alloc_func) (size_t),
                             void *(*realloc_func) (void *, size_t, size_t),
                             void (*free_func) (void *, size_t))
{
}

void FGb_pop_gmp_alloc_fnct()
{
}
