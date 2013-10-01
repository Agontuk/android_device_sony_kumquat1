/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <linux/input.h>

#include "recovery_ui.h"
#include "common.h"
#include "extendedcommands.h"


int device_toggle_display(volatile char* key_pressed, int key_code)
{
    int alt = key_pressed[KEY_LEFTALT] || key_pressed[KEY_RIGHTALT];
    if (alt && key_code == KEY_L)
        return 1;
    return 0;
}

int device_handle_key(int key_code, int visible) {
	if (visible)
	{
		switch (key_code)
		{
			case KEY_CAPSLOCK:
			case KEY_DOWN:
			case KEY_VOLUMEDOWN:
				return HIGHLIGHT_DOWN;

			case KEY_LEFTSHIFT:
			case KEY_UP:
			case KEY_VOLUMEUP:
				return HIGHLIGHT_UP;

			case KEY_POWER:
				return SELECT_ITEM;

			case 528://camera button
                     case KEY_BACKSPACE:
				return GO_BACK;
		}
	}

	return NO_ACTION;
}
