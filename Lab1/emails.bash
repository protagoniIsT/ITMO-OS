#!/bin/bash
> etc_emails.lst
grep -E -R -o -h '[a-zA-Z.+-]+@[a-zA-Z-]+\.[a-zA-Z.-]+' /etc | sort | uniq | tr '\n' ',' >> etc_emails.lst
