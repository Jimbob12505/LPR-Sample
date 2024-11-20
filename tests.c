#include <criterion/criterion.h>
#include "defs.h"
#include <stdio.h>
#include <stdlib.h>

Test(test01, 01) {
    cr_assert_eq(0,0);
}
