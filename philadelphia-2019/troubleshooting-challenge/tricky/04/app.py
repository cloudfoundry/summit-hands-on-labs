#!/usr/bin/env python3.5
# -*- coding: utf-8 -*-

"""simply python cf app
"""

import numpy as np
import datetime
import time

now = datetime.datetime.now()
current_date = now.strftime("%Y-%m-%d")
current_time = now.strftime("%H:%M")
a = np.arange(15).reshape(3, 5)

while True:
    print('CONGRATULATIONS')
    print('you just completed tricky task #04')
    print('---')
    print('Current date and time', current_date, current_time)
    print(a)
    time.sleep(60)
