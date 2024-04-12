//
//  EXTScope.m
//  extobjc
//
//  Created by Justin Spahr-Summers on 2011-05-04.
//  Copyright (C) 2012 Justin Spahr-Summers.
//  Released under the MIT license.
//

#import "LWEXTScope.h"

void lw_executeCleanupBlock (__strong lw_cleanupBlock_t *block) {
    (*block)();
}

