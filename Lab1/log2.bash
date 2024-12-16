#!/bin/bash
> X_info_warn.log
grep '] (WW)' /var/log/Xorg.0.log | sed 's/(WW)/Warning:/g' >> X_info_warn.log
grep '] (II)' /var/log/Xorg.0.log | sed 's/(II)/Information:/g' >> X_info_warn.log


